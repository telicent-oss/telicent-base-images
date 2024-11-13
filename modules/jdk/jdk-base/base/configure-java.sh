#!/bin/bash
# Configure module, POSIX compatible
set -e

SCRIPT_DIR="$(dirname "$0")"
ARTIFACTS_DIR=${SCRIPT_DIR}/scripts
. "${SCRIPT_DIR}"/utils

JAVA_VERSION=${JAVA_INSTALL_VERSION:-"21"}

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

    run_script "./jdk-download" "$JAVA_VERSION"
    run_script "./update-alternatives"
    run_script "./secure-file"

    cd "$CURRENT_DIR" || error_exit "Failed to return to the original directory"

    log "All scripts executed successfully."
}

main
