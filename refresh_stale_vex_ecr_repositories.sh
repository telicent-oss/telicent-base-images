#!/bin/bash

set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
REPO_ROOT="$SCRIPT_DIR"

usage() {
  cat >&2 <<EOF
Usage: $0 [--repos-json <file>] [--output-file <file>] [--registry-id <id>] [--region <region>]

Refresh the curated ECR repository-name list used by the stale OpenVEX workflow.

Notes:
- By default this queries AWS ECR directly.
- Use --repos-json to build the list from a previously captured describe-repositories response.
- Review the generated list before committing; this may include repositories you do not want to scan.
EOF
  exit 1
}

REPOS_JSON=""
OUTPUT_FILE="$REPO_ROOT/.github/stale-vex/ecr-repositories.txt"
REGISTRY_ID="098669589541"
REGION="eu-west-2"

while [[ $# -gt 0 ]]; do
  case "$1" in
    --repos-json)
      shift
      [[ $# -gt 0 ]] || usage
      REPOS_JSON="$1"
      ;;
    --output-file)
      shift
      [[ $# -gt 0 ]] || usage
      OUTPUT_FILE="$1"
      ;;
    --registry-id)
      shift
      [[ $# -gt 0 ]] || usage
      REGISTRY_ID="$1"
      ;;
    --region)
      shift
      [[ $# -gt 0 ]] || usage
      REGION="$1"
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

TMPDIR_REFRESH="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_REFRESH"' EXIT

REPOS_SOURCE_JSON="$TMPDIR_REFRESH/repos.json"

if [[ -n "$REPOS_JSON" ]]; then
  [[ -f "$REPOS_JSON" ]] || { echo "Repos JSON file '$REPOS_JSON' not found." >&2; exit 1; }
  cp "$REPOS_JSON" "$REPOS_SOURCE_JSON"
else
  aws ecr describe-repositories \
    --registry-id "$REGISTRY_ID" \
    --region "$REGION" \
    --output json > "$REPOS_SOURCE_JSON"
fi

jq -r '
  .repositories
  | map(.repositoryName)
  | sort
  | .[]
' "$REPOS_SOURCE_JSON" > "$OUTPUT_FILE"

echo "Wrote $(wc -l < "$OUTPUT_FILE" | tr -d ' ') repository names to $OUTPUT_FILE"
