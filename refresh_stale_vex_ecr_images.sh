#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$SCRIPT_DIR"

usage() {
  cat >&2 <<EOF
Usage: $0 [--repositories-file <file>] [--output-file <file>] [--ecr-registry <registry>]

Resolve the newest SHA-tagged ECR image ref for each repository listed in the repositories file.
EOF
  exit 1
}

REPOSITORIES_FILE="$REPO_ROOT/.github/stale-vex/ecr-repositories.txt"
OUTPUT_FILE="$REPO_ROOT/.github/stale-vex/ecr-images.txt"
ECR_REGISTRY="098669589541.dkr.ecr.eu-west-2.amazonaws.com"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repositories-file)
      shift
      [[ $# -gt 0 ]] || usage
      REPOSITORIES_FILE="$1"
      ;;
    --output-file)
      shift
      [[ $# -gt 0 ]] || usage
      OUTPUT_FILE="$1"
      ;;
    --ecr-registry)
      shift
      [[ $# -gt 0 ]] || usage
      ECR_REGISTRY="$1"
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

[[ -f "$REPOSITORIES_FILE" ]] || { echo "Repositories file '$REPOSITORIES_FILE' not found." >&2; exit 1; }

TMPDIR_REFRESH="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_REFRESH"' EXIT

TMP_OUTPUT="$TMPDIR_REFRESH/ecr-images.txt"

{
  echo "# Generated file. Refresh with:"
  echo "#   ./refresh_stale_vex_ecr_images.sh --repositories-file $REPOSITORIES_FILE --output-file $OUTPUT_FILE"
  while IFS= read -r repository_name; do
    repository_name="$(printf '%s' "$repository_name" | sed 's/^[[:space:]]*//; s/[[:space:]]*$//')"
    [[ -z "$repository_name" ]] && continue
    [[ "$repository_name" == \#* ]] && continue

    image_ref="$ECR_REGISTRY/$repository_name"
    resolved_image_ref="$("$REPO_ROOT/resolve_image_ref.sh" "$image_ref")"
    printf '%s\n' "$resolved_image_ref"
  done < "$REPOSITORIES_FILE"
} > "$TMP_OUTPUT"

mv "$TMP_OUTPUT" "$OUTPUT_FILE"
echo "Wrote $(grep -vc '^\s*#' "$OUTPUT_FILE" || true) image refs to $OUTPUT_FILE"
