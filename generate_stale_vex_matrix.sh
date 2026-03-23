#!/bin/bash

set -euo pipefail

usage() {
  cat >&2 <<EOF
Usage: $0 --public-images-file <file> --ecr-images-file <file>

Builds a JSON matrix for the stale OpenVEX workflow.
- all image refs must already be explicit and ready to scan
EOF
  exit 1
}

PUBLIC_IMAGES_FILE=""
ECR_IMAGES_FILE=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --public-images-file)
      shift
      [[ $# -gt 0 ]] || usage
      PUBLIC_IMAGES_FILE="$1"
      ;;
    --ecr-images-file)
      shift
      [[ $# -gt 0 ]] || usage
      ECR_IMAGES_FILE="$1"
      ;;
    -h|--help)
      usage
      ;;
    *)
      echo "Unknown option: $1" >&2
      usage
      ;;
  esac
  shift
done

[[ -n "$PUBLIC_IMAGES_FILE" && -n "$ECR_IMAGES_FILE" ]] || usage
[[ -f "$PUBLIC_IMAGES_FILE" ]] || { echo "Public images file '$PUBLIC_IMAGES_FILE' not found." >&2; exit 1; }
[[ -f "$ECR_IMAGES_FILE" ]] || { echo "ECR images file '$ECR_IMAGES_FILE' not found." >&2; exit 1; }

TMPDIR_MATRIX="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_MATRIX"' EXIT

PUBLIC_JSON="$TMPDIR_MATRIX/public.json"
ECR_JSON="$TMPDIR_MATRIX/ecr.json"

images_file_to_matrix() {
  local input_file="$1"
  jq -R -s '
  split("\n")
  | map(gsub("^\\s+|\\s+$"; ""))
  | map(select(length > 0 and (startswith("#") | not)))
  | map({
      image: .,
      artifact: (
        if test("@") then
          split("@")[0]
        else
          split(":")[0]
        end
        | split("/")
        | last
      )
    })
  ' "$input_file"
}

images_file_to_matrix "$PUBLIC_IMAGES_FILE" > "$PUBLIC_JSON"
images_file_to_matrix "$ECR_IMAGES_FILE" > "$ECR_JSON"

jq -s 'add | sort_by(.artifact)' "$PUBLIC_JSON" "$ECR_JSON"
