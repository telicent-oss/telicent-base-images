#!/bin/bash

# ==============================================================================
# Script to install GNU Readline with proper ncurses linkage
# ==============================================================================

RED="\033[31m"
END="\033[0m"

log() {
    echo "[INFO] $1"
}

error_exit() {
    echo -e "${RED} [ERROR] $1 ${END}" >&2
    exit 1
}

# Variables
READLINE_VERSION="8.2"
INSTALL_PREFIX="/usr/local"
BUILD_DIR="/tmp/readline-build"
BASE_URL="https://ftp.gnu.org/gnu/readline"
TAR_GZ_URL="${BASE_URL}/readline-${READLINE_VERSION}.tar.gz"
SIG_URL="${BASE_URL}/readline-${READLINE_VERSION}.tar.gz.sig"

log "Fetching GNU Readline ${READLINE_VERSION}..."
mkdir -p "${BUILD_DIR}"
curl -L "${TAR_GZ_URL}" -o "${BUILD_DIR}/readline.tar.gz" || error_exit "Failed to download Readline."
curl -L "${SIG_URL}" -o "${BUILD_DIR}/readline.tar.gz.sig" || error_exit "Failed to download signature file."

log "Extracting GNU Readline..."
tar -xzf "${BUILD_DIR}/readline.tar.gz" -C "${BUILD_DIR}" || error_exit "Failed to extract Readline."

pushd "${BUILD_DIR}/readline-${READLINE_VERSION}" >/dev/null || error_exit "Failed to navigate to Readline build directory."

log "Configuring Readline with proper ncurses linkage..."
./configure --prefix="${INSTALL_PREFIX}" \
    CFLAGS="-I/usr/local/include" \
    LDFLAGS="-L/usr/local/lib -lncurses" || error_exit "Failed to configure Readline."

log "Building Readline..."
make SHLIB_LIBS="-lncurses" || error_exit "Failed to build Readline."

log "Installing Readline..."
make install || error_exit "Failed to install Readline."

popd >/dev/null
log "Cleaning up..."
rm -rf "${BUILD_DIR}" || error_exit "Failed to clean up build directory."

log "Verifying Readline installation..."
if ldd "${INSTALL_PREFIX}/lib/libreadline.so" | grep -q "libncurses"; then
    log "GNU Readline successfully installed and linked with ncurses."
else
    error_exit "Readline installation failed to link with ncurses."
fi
