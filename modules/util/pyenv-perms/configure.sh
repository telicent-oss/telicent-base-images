#!/bin/bash

# ==============================================================================
# Script to configure access to /opt/pyenv for both root and a specific user.
# Ensures /opt is still owned by root:root.
# ==============================================================================

set -e


log() {
    echo "[INFO] $1"
}

error_exit() {
    echo "[ERROR] $1" >&2
    exit 1
}

PYENV_DIR="/opt/pyenv"
PYENV_GROUP="pyenv"
CURRENT_USER=${CURRENT_USER:-}

[ -z "$CURRENT_USER" ] && error_exit "CURRENT_USER environment variable is not set. Exiting."



if [ ! -d "$PYENV_DIR" ]; then
    error_exit "$PYENV_DIR does not exist. Ensure pyenv is installed."
fi

if ! getent group "$PYENV_GROUP" >/dev/null; then
    log "Creating group $PYENV_GROUP..."
    groupadd "$PYENV_GROUP" || error_exit "Failed to create group $PYENV_GROUP."
fi

log "Adding user $CURRENT_USER to group $PYENV_GROUP..."
usermod -aG "$PYENV_GROUP" "$CURRENT_USER" || error_exit "Failed to add user $CURRENT_USER to group $PYENV_GROUP."

log "Changing ownership of $PYENV_DIR to root:$PYENV_GROUP..."
chown -R root:"$PYENV_GROUP" "$PYENV_DIR" || error_exit "Failed to change ownership."

log "Setting permissions on $PYENV_DIR..."
chmod -R 770 "$PYENV_DIR" || error_exit "Failed to set permissions."

log "Applying sticky bit to $PYENV_DIR..."
chmod -R g+s "$PYENV_DIR" || error_exit "Failed to apply sticky bit."

log "Ensuring /opt remains owned by root:root..."
chown root:root /opt || error_exit "Failed to ensure /opt ownership."

log "Configuration of /opt/pyenv access completed successfully for $CURRENT_USER."
