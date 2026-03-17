#!/usr/bin/env bash
set -euo pipefail

SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
CACHE_DIR="${TRIVY_CACHE_DIR:-$SCRIPT_DIR/.cache/trivy}"
TRIVY_ARGS=()

[[ "$(uname)" == "Darwin" ]] || {
  echo "Error: macOS only. Detected: $(uname)" >&2
  exit 1
}

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <image-name>" >&2
  exit 1
fi
IMAGE="$1"

cd "$SCRIPT_DIR"
mkdir -p "$CACHE_DIR"

# enable Bash nullglob (drop non-matching globs)
shopt -s nullglob
VEX_FILES=(./.vex/*.json)
shopt -u nullglob

for vex_file in "${VEX_FILES[@]}"; do
  TRIVY_ARGS+=(--vex "$vex_file")
done

trivy image \
  --cache-dir "$CACHE_DIR" \
  --show-suppressed \
  --severity HIGH,CRITICAL \
  "${TRIVY_ARGS[@]}" \
  "$IMAGE"
