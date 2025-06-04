#!/usr/bin/env bash
set -euo pipefail

# Usage: ./.dev/build-image.sh <path-to-image-descriptor.yaml>
IMAGE_DESC="${1:?Usage: $0 <image-descriptor.yaml>}"

# Activate python virtualenv
VENV_DIR="${VENV_DIR:-venv}"
if [[ ! -d "$VENV_DIR" ]]; then
  python3 -m venv "$VENV_DIR"
fi
source "$VENV_DIR/bin/activate"

# Check pip packages installed
for pkg in cekit docker docker-squash; do
  if ! pip show "$pkg" &>/dev/null; then
    pip install "$pkg"
  fi
done

cekit --descriptor "$IMAGE_DESC" build docker

# Deactivate python virtualenv
deactivate
