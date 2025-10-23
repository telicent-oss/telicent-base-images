#!/usr/bin/env bash
set -euo pipefail

# --- Configuration for Logging ---
# Set to 'true' to enable log messages, 'false' to disable them.
# Setting to 'false' ensures only critical errors and the final grype output are visible.
ENABLE_LOGGING=false

# Function to handle logging. Replaces 'echo' calls for script messages.
# Usage: log "Your message here" [optional: >&2 for stderr]
log() {
  if [[ "$ENABLE_LOGGING" == "true" ]]; then
    if [[ "$#" -ge 2 && "$2" == ">&2" ]]; then
      echo "$1" >&2
    else
      echo "$1"
    fi
  fi
}

# --- Script Start ---

if [[ "$(uname)" == "Darwin" ]]; then
  log "Detected macOS."
else
  # CRITICAL ERROR: Must remain visible
  echo "Error: macOS only. Detected: $(uname)" >&2
  exit 1
fi

if [[ $# -ne 1 ]]; then
  # CRITICAL ERROR: Must remain visible
  echo "Usage: $0 <image-name>" >&2
  exit 1
fi
IMAGE="$1"

# --- Dependencies Check ---
log "Checking dependencies..."
command -v grype >/dev/null 2>&1 || {
  # CRITICAL ERROR: Must remain visible
  echo "Error: grype not found on PATH. Install from https://github.com/anchore/grype" >&2
  exit 1
}
command -v yq >/dev/null 2>&1 || {
  # CRITICAL ERROR: Must remain visible
  echo "Error: yq (v4+) not found on PATH. Install via brew: brew install yq" >&2
  exit 1
}

# --- VEX File Collection ---
log "Collecting VEX files..."
shopt -s nullglob
VEX_FILES=(./.vex/*.json)
shopt -u nullglob

# For cleanup/restore
CLEANUP_FILES=()
RESTORED_ORIGINAL=false
HAD_ORIGINAL=false

if (( ${#VEX_FILES[@]} > 0 )); then
  log "Discovered ${#VEX_FILES[@]} VEX file(s) under ./.vex/:"
  # Suppress the printf output
  # printf ' - %s\n' "${VEX_FILES[@]}" >/dev/null

  tmpdir="$(mktemp -d)"
  CLEANUP_FILES+=("$tmpdir")

  log "Generating per-file ignore blocks from VEX statements..."
  # Generate per-file ignore blocks and then merge them
  TO_MERGE=()
  for vf in "${VEX_FILES[@]}"; do
    out="$tmpdir/$(basename "$vf").grype.yaml"
    yq -o=yaml '
      .statements
      | map(select(.status == "not_affected"))
      | {"ignore": ( map({
            "vulnerability": .vulnerability.name,
            "reason": "'"$(basename "$vf")"': " + (.justification // "not_affected")
          }) ) }
    ' "$vf" > "$out"
    TO_MERGE+=("$out")
  done

  # Merge all generated ignore blocks into one file
  log "Merging all generated ignore blocks..."
  yq eval-all '. as $item ireduce({}; . *+ $item )' "${TO_MERGE[@]}" > .grype.yaml.generated
  log ""
  log "Generated Grype ignore config from VEX:"
  # Suppress cat output
  # cat .grype.yaml.generated >/dev/null
  log ""

  if [[ -f ".grype.yaml" ]]; then
    HAD_ORIGINAL=true
    log "Existing .grype.yaml found. Backing up and merging."
    # Remove -v from cp and use -f for mv to suppress verbose output
    cp .grype.yaml .grype.yaml.original
    CLEANUP_FILES+=(".grype.yaml.original")
    yq eval-all '. as $item ireduce ({}; . *+ $item )' .grype.yaml.original .grype.yaml.generated > .grype.yaml.merged
    mv -f .grype.yaml.merged .grype.yaml
    CLEANUP_FILES+=(".grype.yaml")
    log "Merged Grype config (.grype.yaml):"
    # Suppress cat output
    # cat .grype.yaml >/dev/null
    log ""
    rm -f .grype.yaml.generated
  else
    log "No existing .grype.yaml found. Creating new config."
    # Use -f for mv to suppress verbose output
    mv -f .grype.yaml.generated .grype.yaml
    CLEANUP_FILES+=(".grype.yaml")
    log "Created Grype config (.grype.yaml):"
    # Suppress cat output
    # cat .grype.yaml >/dev/null
    log ""
  fi
fi

# --- Grype Scan ---
# This is the ONLY expected output from the script.
log "Running Grype scan for image: $IMAGE"

grype -q --by-cve --only-fixed --output=table --show-suppressed "docker:$IMAGE"

# --- Cleanup ---

# Restore original config if present
if [[ "$HAD_ORIGINAL" == "true" && -f ".grype.yaml.original" ]]; then
  log "Restoring original .grype.yaml"
  # Use -f for mv to suppress verbose output
  mv -f .grype.yaml.original .grype.yaml
  RESTORED_ORIGINAL=true
fi

# Cleanup temporary files
log "Cleaning up temporary files..."
for f in "${CLEANUP_FILES[@]}"; do
  # If we restored the original .grype.yaml, don't delete it
  if [[ "$RESTORED_ORIGINAL" == "true" && "$f" == ".grype.yaml" ]]; then
    log "Skipping deletion of restored .grype.yaml."
    continue
  fi
  # Use -f for rm to suppress verbose output
  [[ -e "$f" ]] && rm -rf "$f"
done

log "Script execution finished."