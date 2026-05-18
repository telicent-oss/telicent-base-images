#!/usr/bin/env bash
set -euo pipefail

REPO_ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
DESCRIPTOR="$REPO_ROOT/image-descriptors/telicent-base-nodejs22.yaml"

echo "==> Building telicent-nodejs22 from $DESCRIPTOR"
"$REPO_ROOT/.dev/build-image.sh" "$DESCRIPTOR"

IMAGE=$(docker images --format "{{.Repository}}:{{.Tag}}" | grep "^telicent-nodejs22:" | head -1)
if [[ -z "$IMAGE" ]]; then
  echo "ERROR: no telicent-nodejs22 image found after build" >&2
  exit 1
fi

echo "==> Verifying Node version in $IMAGE"
NODE_VER=$(docker run --rm "$IMAGE" node --version)
echo "    node $NODE_VER"

MAJOR=$(echo "$NODE_VER" | sed 's/v\([0-9]*\).*/\1/')
if [[ "$MAJOR" -lt 22 ]]; then
  echo "ERROR: expected Node >=22, got $NODE_VER" >&2
  exit 1
fi

echo "==> OK"
