#!/bin/bash

set -euo pipefail

usage() {
  cat >&2 <<EOF
Usage: $0 <report-dir> <markdown-output> [json-output]
EOF
  exit 1
}

REPORT_DIR="${1:-}"
MARKDOWN_OUTPUT="${2:-}"
JSON_OUTPUT="${3:-}"

[[ -n "$REPORT_DIR" && -n "$MARKDOWN_OUTPUT" ]] || usage
[[ -d "$REPORT_DIR" ]] || { echo "Report directory '$REPORT_DIR' does not exist." >&2; exit 1; }

shopt -s nullglob
REPORT_FILES=( "$REPORT_DIR"/*.json )
shopt -u nullglob

if (( ${#REPORT_FILES[@]} == 0 )); then
  echo "No JSON reports found under '$REPORT_DIR'." >&2
  exit 1
fi

GENERATED_AT="$(date -u +"%Y-%m-%dT%H:%M:%SZ")"
TMP_JSON="$(mktemp)"
trap 'rm -f "$TMP_JSON"' EXIT

jq -s --arg generated_at "$GENERATED_AT" '
  {
    generated_at: $generated_at,
    images: map({
      image: .image,
      summary: .summary
    }),
    files: (
      [ .[] | .results[] ]
      | group_by(.vex_file)
      | map({
          vex_file: .[0].vex_file,
          image_statuses: (map({image, status})),
          active_count: (map(select(.status == "ACTIVE")) | length),
          stale_count: (map(select(.status == "STALE")) | length),
          unrelated_count: (map(select(.status == "UNRELATED")) | length),
          unknown_count: (map(select(.status == "UNKNOWN")) | length),
          removable: (
            (map(select(.status == "ACTIVE" or .status == "UNKNOWN")) | length) == 0
            and
            (map(select(.status == "STALE")) | length) > 0
          )
        })
      | sort_by(.vex_file)
    )
  }
' "${REPORT_FILES[@]}" > "$TMP_JSON"

if [[ -n "$JSON_OUTPUT" ]]; then
  cp "$TMP_JSON" "$JSON_OUTPUT"
fi

{
  echo "# OpenVEX stale statement review"
  echo
  echo "Generated at: $GENERATED_AT"
  echo
  echo "Removal rule: a VEX file is a cleanup candidate only if it is \`STALE\` in at least one image and never \`ACTIVE\` or \`UNKNOWN\` in any scanned image."
  echo
  echo "## Per-image summary"
  jq -r '
    .images[]
    | "- `" + .image + "`: ACTIVE=" + (.summary.ACTIVE | tostring)
      + ", STALE=" + (.summary.STALE | tostring)
      + ", UNRELATED=" + (.summary.UNRELATED | tostring)
      + ", UNKNOWN=" + (.summary.UNKNOWN | tostring)
  ' "$TMP_JSON"
  echo
  if jq -e '.files | map(select(.removable)) | length > 0' "$TMP_JSON" >/dev/null; then
    echo "## Removable candidates"
    jq -r '
      .files
      | map(select(.removable))
      | .[]
      | "- `" + .vex_file + "`: "
        + (
            .image_statuses
            | map(.image + "=" + .status)
            | join(", ")
          )
    ' "$TMP_JSON"
  else
    echo "## Removable candidates"
    echo
    echo "No globally removable VEX files were found."
  fi
  echo
  if jq -e '.files | map(select(.unknown_count > 0)) | length > 0' "$TMP_JSON" >/dev/null; then
    echo "## Needs review"
    jq -r '
      .files
      | map(select(.unknown_count > 0))
      | .[]
      | "- `" + .vex_file + "`: "
        + (
            .image_statuses
            | map(select(.status == "UNKNOWN") | .image)
            | join(", ")
          )
    ' "$TMP_JSON"
  fi
} > "$MARKDOWN_OUTPUT"
