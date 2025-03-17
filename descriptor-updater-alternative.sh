#!/bin/bash
# An alternative script to descriptor-updater-py that
# (a) use bash instead of python
# (b) uses the dockerhub instead of red hat

# Configuration
REGISTRY_URL="https://hub.docker.com/v2"
IMAGE_NAME="redhat/ubi9-minimal"
IMAGE_DESCRIPTORS_DIR="./image-descriptors"

# Function to get image descriptor files
get_image_descriptor_files() {
  find "$IMAGE_DESCRIPTORS_DIR" -type f -print0 | xargs -0 -n 1
}

# Function to get latest non-sha non-source tag
get_latest_non_sha_non_source() {
  local tags_json="$1"
  local tags
  local latest_tag

  tags=$(echo "$tags_json" | jq -r '.results[].name' | grep -v '^sha256-' | grep -v 'source' | grep -v '^latest$')

  if [[ -n "$tags" ]]; then
    latest_tag=$(echo "$tags" | sort -r | head -n 1)
    echo "$latest_tag"
  fi
}

# Function to update image version in a file
update_image_version() {
  local file_path="$1"
  local registry_url="$2"
  local image_name="$3"

  local tags_json
  local latest_tag
  local current_line
  local image_prefix
  local current_version
  local current_tag
  local latest_version
  local latest_tag_num
  local updated_line

  tags_json=$(curl -s "${registry_url}/repositories/${image_name}/tags")
  if [[ $? -ne 0 ]]; then
    echo "Error fetching tags for ${image_name}"
    return 1
  fi

  latest_tag=$(get_latest_non_sha_non_source "$tags_json")

  if [[ -z "$latest_tag" ]]; then
    echo "No valid tags found for ${image_name}"
    return 1
  fi

  while IFS= read -r current_line; do
    if [[ "$current_line" =~ ^from:[[:space:]]*\" ]]; then
      image_prefix=$(echo "$current_line" | awk -F': "' '{print $2}' | awk -F':' '{print $1}')
      current_version_tag=$(echo "$current_line" | awk -F': "' '{print $2}' | tr -d '"')
      current_version_tag=$(echo "$current_version_tag" | awk -F':' '{print $2}')

      # shellcheck disable=SC1073
      if [[ ( -z "$current_version_tag" ) || (! "$current_version_tag" =~ - ) ]]; then
        echo "Skipping line: $current_line. No versioning found."
        echo "$current_line"
        continue
      fi

      current_version=$(echo "$current_version_tag" | awk -F'-' '{print $1}')
      current_tag=$(echo "$current_version_tag" | awk -F'-' '{print $2}')

      latest_version=$(echo "$latest_tag" | awk -F'-' '{print $1}')
      latest_tag_num=$(echo "$latest_tag" | awk -F'-' '{print $2}')

      if [[ "$(echo "$latest_version >= $current_version" | bc)" -eq 1 ]]; then
        if [[ "$latest_tag_num" == "$current_tag" && "$latest_version" == "$current_version" ]]; then
          echo "Nothing to update, current descriptor version is $current_version_tag, latest remote version is $latest_tag"
          echo "$current_line"
          continue
        elif [[ "$latest_tag_num" -lt "$current_tag" && "$latest_version" == "$current_version" ]]; then
          echo "Cannot update version with older tag. Current=$current_tag, Candidate=$latest_tag_num"
          echo "$current_line"
          continue
        fi
      else
        echo "Cannot update version older than the current one. Current=$current_version, Candidate=$latest_version"
        echo "$current_line"
        continue
      fi

      updated_line="from: \"${image_prefix}:${latest_tag}\""
      echo "$updated_line"

      echo "Updated $current_version_tag to ${image_prefix}:${latest_tag}"
    else
      echo "$current_line"
    fi
  done < "$file_path" > "${file_path}.tmp" && mv "${file_path}.tmp" "$file_path"

  echo "Updated ${file_path} to use ${image_name}:${latest_tag}"
}

# Main script
main() {
  local file_path

  if ! command -v jq &> /dev/null
  then
    echo "jq could not be found. Please install it."
    return 1
  fi

  for file_path in $(get_image_descriptor_files); do
    update_image_version "$file_path" "$REGISTRY_URL" "$IMAGE_NAME"
  done
}

main