#!/usr/bin/env bash
  set -euo pipefail

  SCRIPT_DIR="$(cd -- "$(dirname -- "${BASH_SOURCE[0]}")" && pwd)"
  CACHE_DIR="${TRIVY_CACHE_DIR:-$SCRIPT_DIR/.cache/trivy}"
  TRIVY_ARGS=()

  [[ "$(uname)" == "Darwin" ]] || {
    echo "Error: macOS only. Detected: $(uname)" >&2
    exit 1
  }

  usage() {
    echo "Usage:" >&2
    echo "  $0 <image-name>" >&2
    echo "  $0 image <image-name>" >&2
    echo "  $0 fs <path>" >&2
    exit 1
  }

  if [[ $# -eq 1 ]]; then
    MODE="image"
    TARGET="$1"
  elif [[ $# -eq 2 ]]; then
    MODE="$1"
    TARGET="$2"
  else
    usage
  fi

  case "$MODE" in
    image)
      ;;
    fs)
      [[ -e "$TARGET" ]] || {
        echo "Error: fs target does not exist: $TARGET" >&2
        exit 1
      }
      ;;
    *)
      echo "Error: unsupported mode '$MODE' (expected 'image' or 'fs')" >&2
      usage
      ;;
  esac

  cd "$SCRIPT_DIR"
  mkdir -p "$CACHE_DIR"

  shopt -s nullglob
  VEX_FILES=(./.vex/*.json)
  shopt -u nullglob

  for vex_file in "${VEX_FILES[@]}"; do
    TRIVY_ARGS+=(--vex "$vex_file")
  done

  trivy "$MODE" \
    --cache-dir "$CACHE_DIR" \
    --show-suppressed \
    --severity HIGH,CRITICAL \
    "${TRIVY_ARGS[@]}" \
    "$TARGET"