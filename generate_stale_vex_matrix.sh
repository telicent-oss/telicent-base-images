#!/bin/bash

set -euo pipefail

usage() {
  cat >&2 <<EOF
Usage: $0 --public-images-file <file> --ecr-repositories-file <file> [--repos-json <file>]

Builds a JSON matrix for the stale OpenVEX workflow.
- public images are used as-is
- ECR repositories are resolved to repository URIs using AWS describe-repositories output
EOF
  exit 1
}

PUBLIC_IMAGES_FILE=""
ECR_REPOSITORIES_FILE=""
REPOS_JSON=""

while [[ $# -gt 0 ]]; do
  case "$1" in
    --public-images-file)
      shift
      [[ $# -gt 0 ]] || usage
      PUBLIC_IMAGES_FILE="$1"
      ;;
    --ecr-repositories-file)
      shift
      [[ $# -gt 0 ]] || usage
      ECR_REPOSITORIES_FILE="$1"
      ;;
    --repos-json)
      shift
      [[ $# -gt 0 ]] || usage
      REPOS_JSON="$1"
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

[[ -n "$PUBLIC_IMAGES_FILE" && -n "$ECR_REPOSITORIES_FILE" ]] || usage
[[ -f "$PUBLIC_IMAGES_FILE" ]] || { echo "Public images file '$PUBLIC_IMAGES_FILE' not found." >&2; exit 1; }
[[ -f "$ECR_REPOSITORIES_FILE" ]] || { echo "ECR repositories file '$ECR_REPOSITORIES_FILE' not found." >&2; exit 1; }

TMPDIR_MATRIX="$(mktemp -d)"
trap 'rm -rf "$TMPDIR_MATRIX"' EXIT

PUBLIC_JSON="$TMPDIR_MATRIX/public.json"
ECR_JSON="$TMPDIR_MATRIX/ecr.json"
REPOS_JSON_FILE="$TMPDIR_MATRIX/repos.json"

if [[ -n "$REPOS_JSON" ]]; then
  [[ -f "$REPOS_JSON" ]] || { echo "Repos JSON file '$REPOS_JSON' not found." >&2; exit 1; }
  REPOSITORIES_JSON_CONTENT="$(cat "$REPOS_JSON")"
else
  REPOSITORIES_JSON_CONTENT="$(
    aws ecr describe-repositories \
      --registry-id 098669589541 \
      --region eu-west-2 \
      --output json
  )"
fi

printf '%s\n' "$REPOSITORIES_JSON_CONTENT" > "$REPOS_JSON_FILE"

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
' "$PUBLIC_IMAGES_FILE" > "$PUBLIC_JSON"

jq -n \
  --slurpfile repos "$REPOS_JSON_FILE" \
  --rawfile wanted "$ECR_REPOSITORIES_FILE" '
    ($wanted
      | split("\n")
      | map(gsub("^\\s+|\\s+$"; ""))
      | map(select(length > 0 and (startswith("#") | not)))
    ) as $wantedRepos
    |
    ($repos[0].repositories // [])
    | map(select(.repositoryName as $name | $wantedRepos | index($name)))
    | sort_by(.repositoryName)
    | map({
        image: .repositoryUri,
        artifact: .repositoryName
      })
  ' > "$ECR_JSON"

WANTED_ECR_COUNT="$(jq -R -s 'split("\n") | map(gsub("^\\s+|\\s+$"; "")) | map(select(length > 0 and (startswith("#") | not))) | length' "$ECR_REPOSITORIES_FILE")"
FOUND_ECR_COUNT="$(jq 'length' "$ECR_JSON")"

if [[ "$WANTED_ECR_COUNT" != "$FOUND_ECR_COUNT" ]]; then
  echo "One or more configured ECR repositories were not found in describe-repositories output." >&2
  echo "Configured: $WANTED_ECR_COUNT, Found: $FOUND_ECR_COUNT" >&2
  jq -r --slurpfile repos "$REPOS_JSON_FILE" --rawfile wanted "$ECR_REPOSITORIES_FILE" '
    ($wanted
      | split("\n")
      | map(gsub("^\\s+|\\s+$"; ""))
      | map(select(length > 0 and (startswith("#") | not)))
    ) as $wantedRepos
    |
    (($repos[0].repositories // []) | map(.repositoryName)) as $actual
    |
    $wantedRepos[]
    | select($actual | index(.) | not)
  ' >&2
  exit 1
fi

jq -s 'add | sort_by(.artifact)' "$PUBLIC_JSON" "$ECR_JSON"
