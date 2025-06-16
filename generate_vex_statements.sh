#!/bin/bash

# Script to generate OpenVEX JSON files for multiple CVE IDs by first running a Trivy scan
# on a specified Docker image.
# This script requires 'jq', 'uuidgen', and 'trivy' to be installed.

# Function to display script usage instructions.
usage() {
    echo "Usage: $0 <IMAGE_NAME> <CVE_ID_1> [CVE_ID_2 ... CVE_ID_N]"
    echo "  <IMAGE_NAME>      : The Docker image name (e.g., telicent/telicent-java21)."
    echo "                      The script will automatically append ':latest' if no tag is provided."
    echo "  <CVE_ID_N>        : One or more Common Vulnerabilities and Exposures IDs (e.g., CVE-2025-5702)."
    echo ""
    echo "Example: $0 telicent/telicent-java21 CVE-2025-5702 CVE-2025-49794"
    exit 1
}

# --- Pre-requisite Checks ---

# Check if 'jq' is installed. 'jq' is essential for parsing and manipulating JSON.
command -v jq >/dev/null 2>&1 || {
    echo >&2 "Error: 'jq' is not installed."
    echo >&2 "Please install 'jq' using Homebrew: brew install jq"
    exit 1
}

# Check if 'uuidgen' is installed. 'uuidgen' is used to generate unique IDs for OpenVEX documents.
command -v uuidgen >/dev/null 2>&1 || {
    echo >&2 "Error: 'uuidgen' is not installed."
    echo >&2 "This script requires macOS or a system with 'uuidgen'."
    exit 1
}

# Check if 'trivy' is installed. 'trivy' is required to perform the image scan.
command -v trivy >/dev/null 2>&1 || {
    echo >&2 "Error: 'trivy' is not installed."
    echo >&2 "Please install 'trivy' (e.g., using Homebrew: brew install aquasecurity/trivy/trivy)."
    exit 1
}

# Detect architecture and platform
ARCH=$(uname -m)
if [[ "$ARCH" == "arm64" ]]; then
    IS_AARCH64=true
else
    IS_AARCH64=false
fi

# Check if at least two arguments (image name + at least one CVE) are provided.
if [ "$#" -lt 2 ]; then
    usage
fi

# Assign command-line arguments to variables.
IMAGE_NAME="$1"
# Shift the first argument (IMAGE_NAME) out, so "$@" now contains only CVE IDs.
shift
CVE_IDS=("$@") # Store all remaining arguments in an array as CVE IDs.

# Ensure the image name includes a tag, defaulting to ":latest" if none is provided.
if [[ "$IMAGE_NAME" != *":"* ]]; then
    FULL_IMAGE_NAME="${IMAGE_NAME}:latest"
else
    FULL_IMAGE_NAME="${IMAGE_NAME}"
fi

TRIVY_OUTPUT_FILE="trivy_output_$(date +%s).json" # Unique temporary file for the overall scan
VEX_DIR="./.vex" # Define the directory for VEX files

# --- Run Trivy Scan ---
echo "Scanning image '$FULL_IMAGE_NAME' for vulnerabilities (CRITICAL, HIGH severity)..."
trivy image "$FULL_IMAGE_NAME" --severity CRITICAL,HIGH --format json > "$TRIVY_OUTPUT_FILE" 2>/dev/null

# Check if the Trivy scan was successful and produced a non-empty file.
if [ $? -ne 0 ] || [ ! -s "$TRIVY_OUTPUT_FILE" ]; then
    echo "Error: Trivy scan failed or produced an empty output file for '$FULL_IMAGE_NAME'."
    echo "Please check the image name and ensure Trivy has access to it."
    rm -f "$TRIVY_OUTPUT_FILE" # Clean up on failure
    exit 1
fi

echo "Trivy scan completed. Processing output and generating OpenVEX files..."

# --- Data Extraction and OpenVEX Generation for Each CVE ---

# Get the current timestamp in ISO 8601 format (UTC).
CURRENT_TIMESTAMP=$(date -u +"%Y-%m-%dT%H:%M:%SZ")

# Initialize an array to store paths of generated OpenVEX files.
GENERATED_VEX_FILES=()
# Initialize an array to store paths of ALL relevant OpenVEX files (generated + pre-existing).
ALL_VEX_FILES=()

# Loop through each CVE ID provided by the user.
for CURRENT_CVE_ID in "${CVE_IDS[@]}"; do
    echo "--- Processing CVE: $CURRENT_CVE_ID ---"

    # Extract all vulnerability entries from the Trivy report that match the current CVE_ID.
    VULN_DATA=$(jq -c --arg cve "$CURRENT_CVE_ID" '.Results[].Vulnerabilities[] | select(.VulnerabilityID == $cve)' "$TRIVY_OUTPUT_FILE")

    # Initialize variables for the current CVE.
    PRODUCTS_ARRAY=""
    VULN_DESCRIPTION="No description available from Trivy scan for $CURRENT_CVE_ID."
    VULN_TITLE="No title available from Trivy scan for $CURRENT_CVE_ID."

    if [ -z "$VULN_DATA" ]; then
        echo "Warning: CVE ID '$CURRENT_CVE_ID' not found in Trivy scan results for '$FULL_IMAGE_NAME'."
        echo "Generating an OpenVEX file for '$CURRENT_CVE_ID' with no affected products listed."
    else
        # Loop through each vulnerability entry extracted for the CVE.
        while IFS= read -r line; do
            # Extract the PURL (Package URL) for the affected package.
            PURL=$(echo "$line" | jq -r '.PkgIdentifier.PURL')

            if [ -n "$PURL" ]; then
                if [ -z "$PRODUCTS_ARRAY" ]; then
                    PRODUCTS_ARRAY="{\"@id\": \"$PURL\"}"
                else
                    PRODUCTS_ARRAY="$PRODUCTS_ARRAY, {\"@id\": \"$PURL\"}"
                fi
                    # If running on Mac, add an x86_64 variant alongside every aarch64 entry
                    # Else, add an aarch64 variant for each x86_64 entry
                    if [ "$IS_AARCH64" = true ] && [[ "$PURL" == *"arch=aarch64"* ]]; then
                      PURL_X86=${PURL/arch=aarch64/arch=x86_64}
                      PRODUCTS_ARRAY+=", {\"@id\": \"$PURL_X86\"}"
                    elif [ "$IS_AARCH64" = false ] && [[ "$PURL" == *"arch=x86_64"* ]]; then
                       PURL_A64=${PURL/arch=x86_64/arch=aarch64}
                       PRODUCTS_ARRAY+=", {\"@id\": \"$PURL_A64\"}"
                    fi
            fi

            # Capture the vulnerability description and title from the first occurrence.
            if [ -z "$VULN_DESCRIPTION" ]; then
                VULN_DESCRIPTION=$(echo "$line" | jq -r '.Description // "No description available."')
                VULN_TITLE=$(echo "$line" | jq -r '.Title // "No title available."')
            fi
        done <<< "$VULN_DATA"
    fi

    # --- OpenVEX JSON Construction for Current CVE ---

    # Generate a UUID (Universally Unique Identifier) for the OpenVEX document's '@id'.
    VEX_UUID=$(uuidgen | tr '[:upper:]' '[:lower:]')
    VEX_ID="https://openvex.dev/docs/public/vex-${VEX_UUID}"

    OPEN_VEX_JSON=$(cat <<EOF
{
  "@context": "https://openvex.dev/ns/v0.2.0",
  "@id": "$VEX_ID",
  "author": "Telicent Ltd",
  "timestamp": "$CURRENT_TIMESTAMP",
  "version": 1,
  "statements": [
    {
      "vulnerability": {
        "name": "$CURRENT_CVE_ID"
      },
      "timestamp": "$CURRENT_TIMESTAMP",
      "products": [
        $PRODUCTS_ARRAY
      ],
      "status": "not_affected",
      "justification": "vulnerable_code_not_in_execute_path",
      "impact_statement": "$VULN_DESCRIPTION (Vulnerability Title: $VULN_TITLE)."
    }
  ]
}
EOF
)

    # Define the output filename for the current CVE, placing it in the .vex directory.
    OUTPUT_FILE="${VEX_DIR}/${CURRENT_CVE_ID}.openvex.json"

    # Save the generated OpenVEX JSON to the specified output file.
    echo "$OPEN_VEX_JSON" | jq . > "$OUTPUT_FILE"
    echo "OpenVEX file generated for $CURRENT_CVE_ID: $OUTPUT_FILE"

    # Add the generated file to the list for later suppression demonstration.
    GENERATED_VEX_FILES+=("$OUTPUT_FILE")

done # End of CVE_IDS loop

# Add all .openvex.json files from the .vex directory to the ALL_VEX_FILES array for suppression.
for vex_file in "$VEX_DIR"/*.openvex.json; do
    if [ -f "$vex_file" ]; then # Ensure it's a file, not a wildcard if no files exist
        ALL_VEX_FILES+=("$vex_file")
    fi
done

# Clean up the temporary Trivy output file.
rm -f "$TRIVY_OUTPUT_FILE"

echo "OpenVEX file(s) generated successfully."
echo ""
echo "--- Validate suppression ---"

# Join the array of generated VEX files into a space-separated string for the --vex parameter.
VEX_FILES_PARAM=$(printf " --vex %s" "${GENERATED_VEX_FILES[@]}")
# IF we want to run against all existing suppression files (comment above and uncomment below)
#VEX_FILES_PARAM=$(printf " --vex %s" "${ALL_VEX_FILES[@]}")

echo "Running Trivy scan again with ALL generated OpenVEX files to show suppression:"
echo "Command: trivy image $FULL_IMAGE_NAME --severity CRITICAL,HIGH $VEX_FILES_PARAM --show-suppressed --quiet"
trivy image "$FULL_IMAGE_NAME" --severity CRITICAL,HIGH $VEX_FILES_PARAM --show-suppressed --quiet

echo ""
echo "NOTE: The file(s) generated above will need updating manually for: "
echo " - justification, status & impact statement, if incorrect"
