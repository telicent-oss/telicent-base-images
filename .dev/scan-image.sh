#!/usr/bin/env bash
set -euo pipefail

command -v trivy >/dev/null 2>&1 || {
  echo "ERROR: trivy not found. Install via Homebrew: brew install aquasecurity/trivy/trivy"
  exit 1
}
command -v grype >/dev/null 2>&1 || {
  echo "ERROR: grype not found. Install via Homebrew: brew install anchore/grype/grype"
  exit 1
}
command -v docker >/dev/null 2>&1 || {
  echo "ERROR: docker CLI not found. Install Docker Desktop and ensure it's running."
  exit 1
}

# Get docker image; If none passed, then get most recently created local image
if [[ "${1:-}" ]]; then
  IMAGE="$1"
else
  latest_line=$(docker images --format '{{.CreatedAt}}|{{.Repository}}:{{.Tag}}' \
                | sort -r \
                | head -n1)
  IMAGE="${latest_line##*|}"
fi

echo "Scanning local image with Trivy: $IMAGE"
trivy image --severity CRITICAL,HIGH --format table "$IMAGE"

grype db update -vv
echo "Scanning local image with Grype: $IMAGE"
grype "$IMAGE" -o table
