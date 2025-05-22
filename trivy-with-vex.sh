#!/usr/bin/env bash
set -euo pipefail

[[ "$(uname)" == "Darwin" ]] || {
  echo "Error: macOS only. Detected: $(uname)" >&2
  exit 1
}

if [[ $# -ne 1 ]]; then
  echo "Usage: $0 <image-name>" >&2
  exit 1
fi
IMAGE="$1"
 
 # enable Bash nullglob (drop non-matching globs)
shopt -s nullglob
VEX_ARGS=$(printf -- '--vex %s ' ./.vex/*.json)
shopt -u nullglob


trivy image "$IMAGE" \
  --show-suppressed \
  --severity HIGH,CRITICAL \
  $VEX_ARGS
