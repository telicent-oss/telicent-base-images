#!/bin/bash

#====================================================================================================
# Script to update versions in image descriptor files.
# This script expects a JSON-like string of image descriptor names (e.g., "[image1,image2]").
# It will process the list, prepend the correct path (e.g., image-descriptors/<name>.yaml),
# and update their versions.
#====================================================================================================

BASE_DIR="image-descriptors"
# Regex to match the version field it is important to always respect &version pointer
VERSION_REGEX='version: &version\s*\"([0-9]+\.[0-9]+\.[0-9]+)\"'

if [[ -z "$1" || "$1" == "[]" ]]; then
  echo "No image descriptors provided. Exiting."
  exit 0
fi

candidates=$(echo "$1" | tr -d '[]' | tr ',' ' ')

if [[ -z "$candidates" ]]; then
  echo "No valid image descriptors to process. Exiting."
  exit 0
fi

echo "Processing image descriptors: $candidates"

for image_name in $candidates; do
  descriptor_path="${BASE_DIR}/${image_name}.yaml"

  if [[ -f "$descriptor_path" ]]; then
    echo "Updating version in: $descriptor_path"

    current_version=$(grep -Po "$VERSION_REGEX" "$descriptor_path" | sed -E "s/$VERSION_REGEX/\1/")

    if [[ -z "$current_version" ]]; then
      echo "Error: Could not find version in $descriptor_path"
      continue
    fi

    echo "Current version: $current_version"

    IFS='.' read -r major minor patch <<<"$current_version"

    patch=$((patch + 1))

    new_version="${major}.${minor}.${patch}"
    echo "New version: $new_version"

    sed -i.bak -E "s/$VERSION_REGEX/version: \&version \"$new_version\"/" "$descriptor_path" && rm "${descriptor_path}.bak"

    echo "Updated $descriptor_path to version $new_version"
  else
    echo "Error: Descriptor file not found for $image_name at path $descriptor_path"
  fi
done
