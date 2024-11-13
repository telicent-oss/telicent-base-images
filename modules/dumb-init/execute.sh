#!/bin/bash

#===========================================================================================
# Helper script to fetch and install dumb-init (a simple init for containers)
# Given a tini version, the script would retrieve and install tini under /usr/bin
# This script is POSIX compatible and intended for use in image build processes.
#===========================================================================================
set -e

RED="\033[31m"
END="\033[0m"

log() {
    echo "[INFO] $1"
}

error_exit() {
    echo -e "${RED} [ERROR] $1 ${END}" >&2
    exit 1
}

command -v curl >/dev/null 2>&1 || error_exit "curl is missing, please install it."

SCRIPT_DIR=$(dirname "$0")
INIT_VERSION=${INIT_VERSION:-"1.2.5"}
ARCHITECTURE=$(uname -m)

INIT_URL="https://github.com/Yelp/dumb-init/releases/download/v${INIT_VERSION}/dumb-init_${INIT_VERSION}_${ARCHITECTURE}"
INIT_SHA25_URL="https://github.com/Yelp/dumb-init/releases/download/v${INIT_VERSION}/sha256sums"

log "Downloading dumb-init version ${INIT_VERSION} for architecture ${ARCHITECTURE}..."
curl -fsSL "${INIT_URL}" -o "/tmp/dumb-init_${INIT_VERSION}_${ARCHITECTURE}"
curl -fsSL "${INIT_SHA25_URL}" -o /tmp/SHA256SUMS

EXPECTED_SUM=$(grep "dumb-init_${INIT_VERSION}_${ARCHITECTURE}" /tmp/SHA256SUMS | awk '{print $1}' | tr '[:upper:]' '[:lower:]')

if [ -z "$EXPECTED_SUM" ]; then
    error_exit "No checksum found for dumb-init_${INIT_VERSION}_${ARCHITECTURE} in SHA256SUMS"
fi

DOWNLOADED_SUM=$(sha256sum "/tmp/dumb-init_${INIT_VERSION}_${ARCHITECTURE}" | awk '{print $1}' | tr '[:upper:]' '[:lower:]')

if [ "$EXPECTED_SUM" != "$DOWNLOADED_SUM" ]; then
    error_exit "Checksum verification failed! Expected: $EXPECTED_SUM, but got: $DOWNLOADED_SUM"
else
    log "Checksum verification passed!"
fi

log "Installing dumb-init..."

mv /tmp/dumb-init_${INIT_VERSION}_${ARCHITECTURE} /usr/bin/dumb-init
 chmod +x /usr/bin/dumb-init

rm -rf  /tmp/SHA256SUMS

log "dumb-init installed successfully!"
