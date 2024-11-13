#!/bin/bash

#====================================================================================================
# Script to determine which images need to be rebuilt based on recent changes.
# The script builds a module map by scanning all 'module.yaml' files under the modules directory.
# It then checks each image descriptor for modules defined in the 'modules.install' section.
# If any of the modules or their dependencies have changed, the corresponding image is marked for rebuild.
# Handles nested module dependencies and maintains proper mapping to ensure accurate rebuilds.
#
# THIS SCRIPT WOULD NOT RUN ON MACOS
# In case it is necessary to run on macos, install gnu grep via homebrew and refactor this code to
# use ggrep instead use bash 4+
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

# Holds the data produced by `build_module_map`
declare -A module_map

# Build a map of all the names and modules e.g telicent.container.java => modules/jdk
function build_module_map() {
  # Find all module.yaml files in the modules directory
  while IFS= read -r module_yaml; do
    local module_name=$(grep -m 1 'name:' "$module_yaml" | sed -E 's/^name: *"?([^"]*)"?/\1/' | tr -d ' ' | tr -d '\n')

    debug_print "Extracted module_name: '$module_name' from $module_yaml"

    # Check if module_name is not empty before adding to the array
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
# todo: make this better, why not convert to json...
function extract_modules_from_install_section() {
  local file=$1
  local in_modules_section=false
  local in_install_section=false
  local modules_found=()

  # Extract module names in install section, handling nested fields
  while IFS= read -r line; do
    # Check for the 'modules:' section to start processing
    if [[ "$line" =~ ^[[:space:]]*modules: ]]; then
      in_modules_section=true
      continue
    fi

    # Exit the modules section if we encounter another top-level section
    if [[ "$in_modules_section" && ! "$line" =~ ^[[:space:]] ]]; then
      in_modules_section=false
      in_install_section=false
    fi

    # Find the 'install:' section under 'modules:'
    if [[ "$in_modules_section" && "$line" =~ ^[[:space:]]*install: ]]; then
      in_install_section=true
      continue
    fi

    # Stop processing if we exit the install section (when next section starts)
    if [[ "$in_install_section" && ! "$line" =~ ^[[:space:]] ]]; then
      in_install_section=false
    fi

    # Extract module names when in the 'install:' section
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

function check_image_descriptors() {
  local changed_files=$(git diff --name-only HEAD~1)

  for file in $changed_files; do
    if [[ "$file" == *"image-descriptors"* && "$file" == *.yaml ]]; then
      echo "Image descriptor $file has changed."
      return 0
    fi
  done
  return 1
}

# Function to recursively check if a module or its dependencies have changed
function track_module_dependencies() {
  local module_name=$1
  local module_path=${module_map["$module_name"]}

  # Check if the module path exists
  if [[ -z "$module_path" ]]; then
    echo "Module $module_name not found." >&2
    return 1
  fi

  # Check if any files in the module directory have changed
  if git diff --name-only HEAD~1 | grep -q "^$module_path/"; then
    echo "Module $module_name in $module_path has changed."
    return 0
  fi

  # Check for nested modules by extracting from install section
  # shellcheck disable=SC2207
  # Could not get it to work with a mapfile, should read a bash book or summi
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

# Function to check if any module used in the image descriptor has changed - including modules in module
function check_modules_in_image_descriptor() {
  local descriptor_file=$1

  # Extract module names from the 'install' section of the descriptor
  # shellcheck disable=SC2207
  # Could not get it to work with a mapfile, should read a bash book or summi
  local modules_in_descriptor=($(extract_modules_from_install_section "$descriptor_file"))

  # Process each module name found in the modules.install section
  for module_name in "${modules_in_descriptor[@]}"; do
    debug_print "Checking module: $module_name in $descriptor_file"
    # Deal with nested dependencies
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
  local affected_images=()

  build_module_map

  echo "----------------------------------------"
  echo "Module Map:"
  for module in "${!module_map[@]}"; do
    echo "Module: $module => Path: ${module_map[$module]}"
  done
  echo "----------------------------------------"

  # Loop over each image descriptor in the base/ directory
  for descriptor in $(find "$base_dir" -name "*.yaml"); do
    debug_print "Checking image descriptor: $descriptor"

    # Check if the image descriptor has changed
    if git diff --name-only HEAD~1 | grep -q "$descriptor"; then
      echo "Image descriptor $descriptor has changed. Rebuild required."
      local image_name=$(basename "$descriptor" | awk -F'.' '{print $1}')
      affected_images+=("$image_name")
    else
      # If no descriptor changes, check the modules in this descriptor
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
  else
    echo "No images need rebuilding."
  fi
}

detect_image_changes "image-descriptors/"
