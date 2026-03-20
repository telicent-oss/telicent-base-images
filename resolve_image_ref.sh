#!/bin/bash

set -euo pipefail

usage() {
  cat >&2 <<EOF
Usage: $0 <image-ref>

Rules:
  - explicit tags are preserved
  - digests are preserved
  - untagged public refs get :latest
  - untagged ECR refs resolve to the newest 40-char SHA tag
EOF
  exit 1
}

image_ref="${1:-}"
[[ -n "$image_ref" ]] || usage

if [[ "$image_ref" == *"@"* ]]; then
  printf '%s\n' "$image_ref"
  exit 0
fi

last_path_part="${image_ref##*/}"
if [[ "$last_path_part" == *:* ]]; then
  printf '%s\n' "$image_ref"
  exit 0
fi

if [[ "$image_ref" =~ ^([0-9]{12})\.dkr\.ecr\.([a-z0-9-]+)\.amazonaws\.com/(.+)$ ]]; then
  registry_id="${BASH_REMATCH[1]}"
  region="${BASH_REMATCH[2]}"
  repository_name="${BASH_REMATCH[3]}"

  latest_sha_tag="$(
    aws ecr describe-images \
      --registry-id "$registry_id" \
      --repository-name "$repository_name" \
      --region "$region" \
      --output json \
    | jq -r '
        .imageDetails
        | map(select(.imageTags and (.imageTags | length > 0)))
        | sort_by(.imagePushedAt)
        | reverse
        | [.[].imageTags[] | select(test("^[0-9a-f]{40}$"))]
        | first // empty
      '
  )"

  if [[ -z "$latest_sha_tag" ]]; then
    echo "Failed to resolve a SHA tag for ECR image '$image_ref'." >&2
    exit 1
  fi

  printf '%s:%s\n' "$image_ref" "$latest_sha_tag"
  exit 0
fi

printf '%s:latest\n' "$image_ref"
