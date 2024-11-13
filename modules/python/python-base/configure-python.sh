#!/bin/bash
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

SCRIPT_DIR="$(dirname "$0")"
ARTIFACTS_DIR=${SCRIPT_DIR}/scripts

[ -z "${PYTHON_INSTALL_VERSION+x}" ] && error_exit "Python install version must be specified, check your module."

prepare_artifacts() {
    chown -R "${USER}:root" "$SCRIPT_DIR"
    chmod -R ug+rwX "${SCRIPT_DIR}"
    chmod ug+x ${ARTIFACTS_DIR}/*
}


run_script() {
    script_name=$1
    shift
    if [ -f "$script_name" ]; then
        log "Executing $script_name with arguments: $*"
        sh "$script_name" "$@" || error_exit "Failed to execute $script_name"
    else
        error_exit "$script_name not found!"
    fi
}

main() {
    log "Preparing artifacts..."
    prepare_artifacts

    CURRENT_DIR="$(pwd)"

    cd "$ARTIFACTS_DIR" || error_exit "Failed to change directory to $ARTIFACTS_DIR"

    run_script "./install-python" "$PYTHON_INSTALL_VERSION"
    run_script "./ps1-venv"

    cd "$CURRENT_DIR" || error_exit "Failed to return to the original directory"

    log "All scripts executed successfully."
}

main