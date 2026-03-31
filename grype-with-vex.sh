#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
GRYPE_DB_CACHE_DIR="${GRYPE_DB_CACHE_DIR:-$SCRIPT_DIR/.cache/grype/db}"
GRYPE_CHECK_FOR_APP_UPDATE="${GRYPE_CHECK_FOR_APP_UPDATE:-false}"
ENABLE_LOGGING="${ENABLE_LOGGING:-false}"

export GRYPE_DB_CACHE_DIR
export GRYPE_CHECK_FOR_APP_UPDATE

cleanup_paths=()

log() {
  if [[ "$ENABLE_LOGGING" == "true" ]]; then
    echo "$*"
  fi
}

cleanup() {
  local status=$?

  for path in "${cleanup_paths[@]:-}"; do
    [[ -e "$path" ]] && rm -rf "$path"
  done

  exit "$status"
}

build_scan_target() {
  local target=$1

  case "$target" in
    docker:*|podman:*|registry:*|docker-archive:*|oci-archive:*|oci-dir:*|singularity:*|dir:*|file:*|sbom:*|purl:*|cpes:*)
      printf '%s\n' "$target"
      return
      ;;
  esac

  if [[ -d "$target" ]]; then
    printf 'dir:%s\n' "$target"
    return
  fi

  if [[ -f "$target" ]]; then
    case "$target" in
      *.json|*.xml)
        printf 'sbom:%s\n' "$target"
        ;;
      *)
        printf 'file:%s\n' "$target"
        ;;
    esac
    return
  fi

  # Let Grype apply its default source resolution for image references.
  printf '%s\n' "$target"
}

trap cleanup EXIT

[[ "$(uname)" == "Darwin" ]] || {
  echo "Error: macOS only. Detected: $(uname)" >&2
  exit 1
}

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <target>" >&2
  exit 1
fi

TARGET="$1"
SCAN_TARGET="$(build_scan_target "$TARGET")"

cd "$SCRIPT_DIR"
mkdir -p "$GRYPE_DB_CACHE_DIR"

command -v grype >/dev/null 2>&1 || {
  echo "Error: grype not found on PATH. Install from https://github.com/anchore/grype" >&2
  exit 1
}

shopt -s nullglob
VEX_FILES=(./.vex/*.json)
shopt -u nullglob

GRYPE_ARGS=(
  --by-cve
  --output=table
  --sort-by=severity
  --show-suppressed
)

if (( ${#VEX_FILES[@]} > 0 )); then
  command -v yq >/dev/null 2>&1 || {
    echo "Error: yq (v4+) not found on PATH. Install via brew: brew install yq" >&2
    exit 1
  }

  tmpdir="$(mktemp -d)"
  cleanup_paths+=("$tmpdir")

  log "Generating temporary Grype ignore rules from ${#VEX_FILES[@]} VEX file(s)."

  per_file_configs=()
  for vf in "${VEX_FILES[@]}"; do
    out="$tmpdir/$(basename "$vf").grype.yaml"
    yq -o=yaml '
      .statements
      | map(select(.status == "not_affected"))
      | {
          "ignore": (
            map({
              "vulnerability": .vulnerability.name,
              "reason": "'"$(basename "$vf")"': " + (.justification // "not_affected")
            })
          )
        }
    ' "$vf" > "$out"
    per_file_configs+=("$out")
  done

  generated_config="$tmpdir/grype.generated.yaml"
  yq eval-all '. as $item ireduce({}; . *+ $item )' "${per_file_configs[@]}" > "$generated_config"

  if [[ -f ".grype.yaml" ]]; then
    merged_config="$tmpdir/grype.merged.yaml"
    yq eval-all '. as $item ireduce({}; . *+ $item )' .grype.yaml "$generated_config" > "$merged_config"
    GRYPE_ARGS+=(-c "$merged_config")
  else
    GRYPE_ARGS+=(-c "$generated_config")
  fi
fi

log "Scanning target: $SCAN_TARGET"

if ! grype "${GRYPE_ARGS[@]}" "$SCAN_TARGET"; then
  echo "Error: grype scan failed for target '$TARGET' (resolved as '$SCAN_TARGET')." >&2
  exit 1
fi
