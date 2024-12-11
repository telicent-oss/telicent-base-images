#!/bin/bash

#====================================================================================================
# Script to determine which images need to be rebuilt based on changes between the last two merge commits.
# The script builds a module map by scanning all 'module.yaml' files under the modules directory.
# It then checks each image descriptor for modules defined in the 'modules.install' section.
# If any of the modules or their dependencies have changed, the corresponding image is marked for rebuild.
# Handles nested module dependencies and maintains proper mapping to ensure accurate rebuilds.
#
# THIS SCRIPT WOULD NOT RUN ON MACOS
# In case it is necessary to run on macOS, install gnu grep via homebrew and refactor this code to
# use ggrep instead. Ensure Bash 4+ is used.
#====================================================================================================


DEBUG=${DEBUG:-0}

if [[ "${BASH_VERSINFO[0]}" -lt 4 ]]; then
  echo "This script requires Bash 4.0 or higher due to associative arrays."
  exit 1
fi

function debug_print() {
  if [[ "$DEBUG" == 1 ]]; then
    echo "[DEBUG] $1"
  fi
}

function get_commit_range() {
  # Get the most recent tag in the repository, sorted by creation date
  tags=($(git tag --sort=-creatordate | head -n 2))

  if [[ ${#tags[@]} -ge 2 ]]; then
    last_tag="${tags[0]}" # Pick the most recent tag
    last_tag=$(git log --oneline $last_tag..HEAD | tail -1 | awk '{print $1}')
    echo "$last_tag HEAD"
  else
    # Generally, everything else compare from base of the repo, as soon
    # there are 2 tags this will never execute anyway
    echo "$(git rev-list --max-parents=0 HEAD) HEAD"
  fi
}

# Holds the data produced by `build_module_map`
declare -A module_map

# Build a map of all the names and modules e.g. telicent.container.java => modules/jdk
function build_module_map() {
  while IFS= read -r module_yaml; do
    local module_name=$(grep -m 1 'name:' "$module_yaml" | sed -E 's/^name: *"?([^"]*)"?/\1/' | tr -d ' ' | tr -d '\n')

    debug_print "Extracted module_name: '$module_name' from $module_yaml"

    if [[ -z "$module_name" ]]; then
      echo "Error: No module name found in $module_yaml" >&2
      continue
    fi

    local module_dir=$(dirname "$module_yaml")
    module_map["$module_name"]="$module_dir"
    debug_print "Mapped module $module_name to $module_dir"
  done < <(find modules -name module.yaml)
}

# Function to extract module names from the install section
function extract_modules_from_install_section() {
  local file=$1
  local in_modules_section=false
  local in_install_section=false
  local modules_found=()

  while IFS= read -r line; do
    if [[ "$line" =~ ^[[:space:]]*modules: ]]; then
      in_modules_section=true
      continue
    fi

    if [[ "$in_modules_section" && ! "$line" =~ ^[[:space:]] ]]; then
      in_modules_section=false
      in_install_section=false
    fi

    if [[ "$in_modules_section" && "$line" =~ ^[[:space:]]*install: ]]; then
      in_install_section=true
      continue
    fi

    if [[ "$in_install_section" && ! "$line" =~ ^[[:space:]] ]]; then
      in_install_section=false
    fi

    if $in_install_section && [[ "$line" =~ ^[[:space:]]*-?[[:space:]]*name: ]]; then
      local module_name=$(echo "$line" | grep -oP '(?<=name: )\S+')
      module_name=$(echo "$module_name" | tr -d ' ' | tr -d '\n')

      if [[ -n "$module_name" ]]; then
        modules_found+=("$module_name")
      fi
    fi
  done < "$file"

  echo "${modules_found[@]}"
}

# Function to recursively check if a module or its dependencies have changed
function track_module_dependencies() {
  local module_name=$1
  local module_path=${module_map["$module_name"]}

  if [[ -z "$module_path" ]]; then
    echo "Module $module_name not found." >&2
    return 1
  fi

  if git diff --name-only "$END_REF" "$START_REF" | grep -q "^$module_path/"; then
    echo "Module $module_name in $module_path has changed."
    return 0
  fi

  local nested_modules=($(extract_modules_from_install_section "$module_path/module.yaml"))
  if [[ ${#nested_modules[@]} -gt 0 ]]; then
    debug_print "Checking nested modules in $module_name"
    for nested_module in "${nested_modules[@]}"; do
      if track_module_dependencies "$nested_module"; then
        echo "Nested module $nested_module in $module_name has changed."
        return 0
      fi
    done
  else
    debug_print "$module_name has no nested modules."
  fi

  return 1
}

# Function to check if any module used in the image descriptor has changed
function check_modules_in_image_descriptor() {
  local descriptor_file=$1
  local modules_in_descriptor=($(extract_modules_from_install_section "$descriptor_file"))

  for module_name in "${modules_in_descriptor[@]}"; do
    debug_print "Checking module: $module_name in $descriptor_file"
    if track_module_dependencies "$module_name"; then
      echo "$descriptor_file requires build since $module_name dependant on it has changed."
      return 0
    fi
  done

  return 1
}

# Function to detect changes in images based on modules
function detect_image_changes() {
  local base_dir=$1
  echo "Base dir: ${base_dir}"
  local affected_images=()

  # Get the last two merge commits
  read -r START_REF END_REF < <(get_commit_range)
  echo "Start sha:${START_REF} - End: $END_REF"
  if [[ -z "$START_REF" || -z "$END_REF" ]]; then
    echo "Error: Unable to find two merge commits. Ensure there is enough merge history."
    exit 1
  fi

  build_module_map

  echo "----------------------------------------"
  echo "Module Map:"
  for module in "${!module_map[@]}"; do
    echo "Module: $module => Path: ${module_map[$module]}"
  done
  echo "----------------------------------------"

  for descriptor in $(find "$base_dir" -name "*.yaml"); do
    debug_print "Checking image descriptor: $descriptor"

    if git diff --name-only "$END_REF" "$START_REF" | grep -q "$descriptor"; then
      echo "Image descriptor $descriptor has changed. Rebuild required."
      local image_name=$(basename "$descriptor" | awk -F'.' '{print $1}')
      affected_images+=("$image_name")
    else
      if check_modules_in_image_descriptor "$descriptor"; then
        local image_name=$(basename "$descriptor" | awk -F'.' '{print $1}')
        affected_images+=("$image_name")
      fi
    fi
  done

  if [[ "${#affected_images[@]}" -gt 0 ]]; then
    echo "Affected images to rebuild:"
    for image in "${affected_images[@]}"; do
      echo "$image"
    done

    matrix_output=$(IFS=','; echo "${affected_images[*]}")
    echo "Changed image descriptor(s): $matrix_output"

    [[ -n "$GITHUB_ENV" ]] && echo "changed_images=$matrix_output" >> "$GITHUB_ENV"
  else
    echo "No images need rebuilding."
    [[ -n "$GITHUB_ENV" ]] && echo "changed_images=[]" >> "$GITHUB_ENV"
  fi
}

detect_image_changes "image-descriptors"
