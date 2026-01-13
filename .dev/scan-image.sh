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
command -v yq >/dev/null 2>&1 || {
  echo "ERROR: yq (v4+) not found. Install via Homebrew: brew install yq"
  exit 1
}
command -v docker >/dev/null 2>&1 || {
  echo "ERROR: docker CLI not found. Install Docker Desktop and ensure it's running."
  exit 1
}
if [[ ! -x "./trivy-with-vex.sh" ]]; then
  echo "ERROR: ./trivy-with-vex.sh not found or not executable."
  exit 1
fi
if [[ ! -x "./grype-with-vex.sh" ]]; then
  echo "ERROR: ./grype-with-vex.sh not found or not executable."
  exit 1
fi

# Get docker image; If none passed, then get most recently created local image
if [[ "${1:-}" ]]; then
  IMAGE="$1"
else
  latest_line=$(docker images --format '{{.CreatedAt}}|{{.Repository}}:{{.Tag}}' \
                | sort -r \
                | head -n1)
  IMAGE="${latest_line##*|}"
fi

echo "Scanning local image with Trivy (VEX suppressions): $IMAGE"
./trivy-with-vex.sh "$IMAGE"

echo "Scanning local image with Grype (VEX suppressions): $IMAGE"
./grype-with-vex.sh "$IMAGE"
