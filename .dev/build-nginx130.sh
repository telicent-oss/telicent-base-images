#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DESCRIPTOR="$REPO_ROOT/image-descriptors/telicent-base-nginx130.yaml"

echo "==> Building telicent-nginx1.30 from $DESCRIPTOR"
"$REPO_ROOT/.dev/build-image.sh" "$DESCRIPTOR"

IMAGE=$(docker images --format "{{.Repository}}:{{.Tag}}" | grep "^telicent-nginx1\.30:" | head -1)
if [[ -z "$IMAGE" ]]; then
  echo "ERROR: no telicent-nginx1.30 image found after build" >&2
  exit 1
fi

echo "==> Verifying nginx version in $IMAGE"
NGINX_VER=$(docker run --rm "$IMAGE" nginx -v 2>&1)
echo "    $NGINX_VER"

# nginx -v outputs: "nginx version: nginx/1.30.x"
VERSION=$(echo "$NGINX_VER" | sed 's|.*nginx/\([0-9]*\.[0-9]*\).*|\1|')
MAJOR=$(echo "$VERSION" | cut -d. -f1)
MINOR=$(echo "$VERSION" | cut -d. -f2)

if [[ "$MAJOR" -lt 1 ]] || { [[ "$MAJOR" -eq 1 ]] && [[ "$MINOR" -lt 30 ]]; }; then
  echo "ERROR: expected nginx >=1.30, got $NGINX_VER" >&2
  exit 1
fi

echo "==> OK"
