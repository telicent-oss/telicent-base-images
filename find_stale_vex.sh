#!/bin/bash

set -euo pipefail

# Identify VEX files that are stale.
# Ignore any that are unrelated by also checking whether the
# referenced library/product exists in the image SBOM.
#
# Usage:
#   ./find_stale_vex.sh <image[:tag]>
# Default: will use the ubi9-minimal instance used in this repo (not necessarily latest).
#

usage() {
  cat >&2 <<EOF
Usage: $0 [--format text|json] [--json-output <file>] [image[:tag]]
EOF
  exit 1
}

# ---- Create temp dir ----
mktempf() {
  # Try GNU-ish mktemp, fall back to macOS style (-t)
  local t
  t="$(mktemp 2>/dev/null || mktemp -t vex)" || {
    # Last-ditch fallback (not secure, but avoids hard failure)
    t="${TMPDIR:-/tmp}/vex.$$.$RANDOM"
    : > "$t"
  }
  printf '%s\n' "$t"
}

# ---- Make sure we have trivy, jq & awk available ----
for cmd in trivy jq awk; do
  command -v "$cmd" >/dev/null 2>&1 || { echo "Error: '$cmd' is required." >&2; exit 1; }
done

# ---- Parse arguments ----
OUTPUT_FORMAT="text"
JSON_OUTPUT=""
IMAGE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --format)
      shift
      [[ $# -gt 0 ]] || usage
      OUTPUT_FORMAT="$1"
      ;;
    --json-output)
      shift
      [[ $# -gt 0 ]] || usage
      JSON_OUTPUT="$1"
      ;;
    -h|--help)
      usage
      ;;
    --)
      shift
      break
      ;;
    -*)
      echo "Unknown option: $1" >&2
      usage
      ;;
    *)
      if [[ -n "$IMAGE" ]]; then
        usage
      fi
      IMAGE="$1"
      ;;
  esac
  shift
done

case "$OUTPUT_FORMAT" in
  text|json) ;;
  *)
    echo "Unsupported format '$OUTPUT_FORMAT'. Use 'text' or 'json'." >&2
    exit 1
    ;;
esac

say() {
  if [[ "$OUTPUT_FORMAT" == "json" ]]; then
    printf '%s\n' "$*" >&2
  else
    printf '%s\n' "$*"
  fi
}

array_to_json() {
  if (( $# == 0 )); then
    printf '[]'
  else
    printf '%s\n' "$@" | jq -R . | jq -s .
  fi
}

array_len() {
  printf '%s\n' "$#"
}

if [[ -z "$IMAGE" ]]; then
  IMAGE=$(grep "ubi9-minimal" image-descriptors/telicent-base-java.yaml | awk -F\" '{print $2}')
fi

SEVERITY="CRITICAL,HIGH"
VEX_DIR="./.vex"
JSON_ITEMS="$(mktempf)"

# ---- Colour the output ----
if [ -t 1 ] && [[ "$OUTPUT_FORMAT" == "text" ]]; then
  RED="$(tput setaf 1)"; GREEN="$(tput setaf 2)"; YELLOW="$(tput setaf 3)"
  BLUE="$(tput setaf 4)"; BOLD="$(tput bold)"; RESET="$(tput sgr0)"
else
  RED=""; GREEN=""; YELLOW=""; BLUE=""; BOLD=""; RESET=""
fi

# ---- Collect the VEX files ----
shopt -s nullglob
VEX_FILES=( "$VEX_DIR"/*.openvex.json )
shopt -u nullglob
if (( ${#VEX_FILES[@]} == 0 )); then
  EMPTY_REPORT="$(jq -nc \
    --arg image "$IMAGE" \
    --arg vex_dir "$VEX_DIR" \
    '{image: $image, vex_dir: $vex_dir, summary: {ACTIVE: 0, STALE: 0, UNRELATED: 0, UNKNOWN: 0}, results: []}')"
  if [[ -n "$JSON_OUTPUT" ]]; then
    printf '%s\n' "$EMPTY_REPORT" > "$JSON_OUTPUT"
  fi
  if [[ "$OUTPUT_FORMAT" == "json" ]]; then
    printf '%s\n' "$EMPTY_REPORT"
  else
    echo "No VEX files found in '$VEX_DIR' (looked for *.openvex.json)."
  fi
  exit 0
fi

# ---- Trivy scan for CVEs (baseline, no VEX) ----
SCAN_JSON="$(mktempf)"
PRESENT_CVES="$(mktempf)"
SBOM_JSON="$(mktempf)"
SBOM_PURLS="$(mktempf)"
SBOM_NAMES="$(mktempf)"
cleanup() { rm -f "$SCAN_JSON" "$PRESENT_CVES" "$SBOM_JSON" "$SBOM_PURLS" "$SBOM_NAMES" "$JSON_ITEMS"; }
trap cleanup EXIT

say "Scanning image '${IMAGE}' with Trivy (severity: ${SEVERITY})..."
trivy image "${IMAGE}" --severity "${SEVERITY}" --format json > "$SCAN_JSON"

# Unique set of currently present CVE IDs
jq -r '.Results[]? | .Vulnerabilities[]? | .VulnerabilityID' "$SCAN_JSON" \
  | sort -u > "$PRESENT_CVES"

has_cve() { grep -Fxq "$1" "$PRESENT_CVES"; }

# ---- Build SBOM (CycloneDX) and extract component identifiers ----
say "Generating CycloneDX SBOM for '${IMAGE}'..."
trivy image "${IMAGE}" --format cyclonedx --output "$SBOM_JSON" >/dev/null

# purls (exact, best signal)
jq -r '.components[]? | .purl // empty' "$SBOM_JSON" | sort -u > "$SBOM_PURLS"

# names (group:name and plain name, for fuzzy matches)
jq -r '
  .components[]? |
  [
    (if .group then (.group + ":" + .name) else empty end),
    (.name // empty)
  ] | .[]' "$SBOM_JSON" \
  | awk 'NF' | tr '[:upper:]' '[:lower:]' | sort -u > "$SBOM_NAMES"

has_purl() {
  local needle="$1"
  [[ -z "$needle" ]] && return 1
  grep -Fxq "$needle" "$SBOM_PURLS"
}

has_name_like() {
  local needle
  needle="$(echo "$1" | tr '[:upper:]' '[:lower:]')"
  [[ -z "$needle" ]] && return 1
  grep -Fxqi "$needle" "$SBOM_NAMES" || grep -Fqi "$needle" "$SBOM_NAMES"
}

# ---- extract CVEs from VEX file ----
extract_cves_from_vex() {
  local f="$1"
  local cves
  cves="$(jq -r '.statements[]? | .vulnerability.name // empty' "$f" | sort -u)"
  if [[ -z "$cves" ]]; then
    if [[ "$(basename "$f")" =~ (CVE-[0-9]{4}-[0-9]+) ]]; then
      cves="${BASH_REMATCH[1]}"
    fi
  fi
  echo "$cves"
}

# ---- extract product identifiers from VEX file ----
extract_products_from_vex() {
  local f="$1"
  jq -r '
    def product_nodes:
      (.products[]?, .subcomponents[]?) | recurse(.subcomponents[]?);

    .statements[]?
    | product_nodes
    | [
        .purl?,
        .id?,
        .["@id"]?,
        (.ids[]?),
        .name?
      ]
    | .[]
    | select(type == "string" and length > 0)
  ' "$f" 2>/dev/null || true
}

# ---- Process files ----
STALE=0; ACTIVE=0; UNRELATED=0; UNKNOWN=0
STALE_LIST=(); UNRELATED_LIST=()

say ""
say "${BOLD}VEX applicability report for ${IMAGE}${RESET}"
say "VEX directory: ${VEX_DIR}"
say ""

for f in "${VEX_FILES[@]}"; do
  CVE_LIST="$(extract_cves_from_vex "$f")"

  RAW_PRODS="$(extract_products_from_vex "$f" | awk 'NF' | sort -u)"

  VEX_PURLS=()
  VEX_NAMES=()

  # Split lines into purls vs names
  while IFS= read -r line; do
    [[ -z "$line" ]] && continue
    if [[ "$line" =~ ^pkg: ]]; then
      VEX_PURLS+=( "$line" )
    else
      # Keep reasonably short strings only (avoid blobs)
      if [ ${#line} -le 200 ]; then
        VEX_NAMES+=( "$line" )
      fi
    fi
  done <<< "$RAW_PRODS"

  # If still no purls, try to grep for pkg: purls anywhere in the file
  if (( ${#VEX_PURLS[@]} == 0 )); then
    while IFS= read -r p; do
      [[ -n "$p" ]] && VEX_PURLS+=( "$p" )
    done < <(grep -Eo 'pkg:[A-Za-z0-9._+/@:%-]+([@?][A-Za-z0-9._+:/%#;=,-]+)?' "$f" | sort -u || true)
  fi

  # Deduplicate/lower names
  _tmp_names="$(mktempf)"
  # shellcheck disable=SC2068
  printf "%s\n" ${VEX_NAMES[@]+"${VEX_NAMES[@]}"} | tr '[:upper:]' '[:lower:]' | awk 'NF' | sort -u > "$_tmp_names"
  VEX_NAMES=()
  while IFS= read -r n; do
    VEX_NAMES+=( "$n" )
  done < "$_tmp_names"
  rm -f "$_tmp_names"

  present_cves=(); absent_cves=()
  if [[ -n "$CVE_LIST" ]]; then
    while read -r cve; do
      [[ -z "$cve" ]] && continue
      if has_cve "$cve"; then present_cves+=( "$cve" ); else absent_cves+=( "$cve" ); fi
    done <<< "$CVE_LIST"
  fi

  matched_purls=(); missing_purls=()
  if (( $(array_len ${VEX_PURLS[@]+"${VEX_PURLS[@]}"}) > 0 )); then
    for p in "${VEX_PURLS[@]}"; do
      if has_purl "$p"; then matched_purls+=( "$p" ); else missing_purls+=( "$p" ); fi
    done
  fi

  matched_names=(); missing_names=()
  if (( $(array_len ${VEX_NAMES[@]+"${VEX_NAMES[@]}"}) > 0 )); then
    for n in "${VEX_NAMES[@]}"; do
      if has_name_like "$n"; then matched_names+=( "$n" ); else missing_names+=( "$n" ); fi
    done
  fi

  any_lib_known=$(( ${#VEX_PURLS[@]} + ${#VEX_NAMES[@]} ))
  any_lib_present=$(( ${#matched_purls[@]} + ${#matched_names[@]} ))
  any_cve_present=$(( ${#present_cves[@]} ))

  status=""
  if (( any_lib_known > 0 )) && (( any_lib_present == 0 )); then
    status="UNRELATED"
  elif (( any_cve_present == 0 )) && (( any_lib_present > 0 )); then
    status="STALE"
  elif (( any_cve_present > 0 )) && (( any_lib_present > 0 )); then
      status="ACTIVE"
  else
    if [[ -z "$CVE_LIST" ]]; then
      status="UNKNOWN"
    else
      if (( ${#present_cves[@]} == 0 )); then status="STALE"; else status="ACTIVE"; fi
    fi
  fi

  case "$status" in
    ACTIVE)        say "${GREEN}ACTIVE${RESET}        $f"; ((ACTIVE++)) ;;
    STALE)     say "${YELLOW}STALE${RESET}      $f"; STALE_LIST+=( "$f" ); ((STALE++)) ;;
    UNRELATED) say "${BLUE}UNRELATED${RESET}  $f"; UNRELATED_LIST+=( "$f" ); ((UNRELATED++)) ;;
    *)         say "${RED}UNKNOWN${RESET}    $f  (no usable product metadata)"; ((UNKNOWN++)) ;;
  esac

  [[ -n "$CVE_LIST" ]] && say "           CVEs  -> present:[${present_cves[*]:-}]  gone:[${absent_cves[*]:-}]"
  if (( any_lib_known > 0 )); then
    (( ${#matched_purls[@]} )) && say "           PURLs -> present:[${matched_purls[*]}]"
    (( ${#missing_purls[@]} )) && say "                   absent:[${missing_purls[*]}]"
    (( ${#matched_names[@]} )) && say "           Names -> present:[${matched_names[*]}]"
    (( ${#missing_names[@]} )) && say "                   absent:[${missing_names[*]}]"
  fi

  jq -nc \
    --arg image "$IMAGE" \
    --arg vex_file "$f" \
    --arg status "$status" \
    --argjson present_cves "$(array_to_json ${present_cves[@]+"${present_cves[@]}"})" \
    --argjson absent_cves "$(array_to_json ${absent_cves[@]+"${absent_cves[@]}"})" \
    --argjson matched_purls "$(array_to_json ${matched_purls[@]+"${matched_purls[@]}"})" \
    --argjson missing_purls "$(array_to_json ${missing_purls[@]+"${missing_purls[@]}"})" \
    --argjson matched_names "$(array_to_json ${matched_names[@]+"${matched_names[@]}"})" \
    --argjson missing_names "$(array_to_json ${missing_names[@]+"${missing_names[@]}"})" \
    '{
      image: $image,
      vex_file: $vex_file,
      status: $status,
      present_cves: $present_cves,
      absent_cves: $absent_cves,
      matched_purls: $matched_purls,
      missing_purls: $missing_purls,
      matched_names: $matched_names,
      missing_names: $missing_names
    }' >> "$JSON_ITEMS"
done

say ""
say "${BOLD}Summary:${RESET}  ACTIVE=${ACTIVE}  STALE=${STALE}  UNRELATED=${UNRELATED}  UNKNOWN=${UNKNOWN}"

REPORT_JSON="$(jq -nc \
  --arg image "$IMAGE" \
  --arg vex_dir "$VEX_DIR" \
  --argjson active "$ACTIVE" \
  --argjson stale "$STALE" \
  --argjson unrelated "$UNRELATED" \
  --argjson unknown "$UNKNOWN" \
  --slurpfile results "$JSON_ITEMS" \
  '{
    image: $image,
    vex_dir: $vex_dir,
    summary: {
      ACTIVE: $active,
      STALE: $stale,
      UNRELATED: $unrelated,
      UNKNOWN: $unknown
    },
    results: $results
  }')"

if [[ -n "$JSON_OUTPUT" ]]; then
  printf '%s\n' "$REPORT_JSON" > "$JSON_OUTPUT"
fi

if [[ "$OUTPUT_FORMAT" == "json" ]]; then
  printf '%s\n' "$REPORT_JSON"
fi
