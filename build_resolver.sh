#!/usr/bin/env bash

#====================================================================================================
# Script to determine which images need to be rebuilt based on changes between the last two merge commits.
# The script builds a module map by scanning all 'module.yaml' files under the modules directory.
# It then checks each image descriptor for modules defined in the 'modules.install' section.
# If any of the modules or their dependencies have changed, the corresponding image is marked for rebuild.
# Handles nested module dependencies and maintains proper mapping to ensure accurate rebuilds.
#====================================================================================================

DEBUG=${DEBUG:-0}

# No longer checking Bash version; Zsh and Bash 3+ should work with adjustments

function debug_print() {
  if [[ "$DEBUG" == 1 ]]; then
    echo "[DEBUG] $1"
  fi
}

function get_commit_range() {
  tags=($(git tag --sort=-creatordate | head -n 2))

  if [[ "$1" == "use_last" ]]; then
    last_tag="${tags[0]}"
  else
    last_tag="${tags[1]}"
  fi

  if [[ -z "$last_tag" ]]; then
    echo "$(git rev-list --max-parents=0 HEAD) HEAD"
  else
    echo "$last_tag HEAD"
  fi
}

declare -a module_map_keys
declare -a module_map_values

function build_module_map() {
  find modules -name module.yaml -print0 | while IFS= read -r -d $'\0' module_yaml; do
    module_name=$(grep -m 1 'name:' "$module_yaml" | sed -E 's/^name: *"?([^"]*)"?/\1/' | tr -d ' ' | tr -d '\n')

    debug_print "Extracted module_name: '$module_name' from $module_yaml"

    if [[ -z "$module_name" ]]; then
      echo "Error: No module name found in $module_yaml" >&2
      continue
    fi

    module_dir=$(dirname "$module_yaml")

    # Simulate associative array
    module_map_keys+=("$module_name")
    module_map_values+=("$module_dir")

    debug_print "Mapped module $module_name to $module_dir"
  done
}

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
      local module_name=$(echo "$line" | grep -o '(?<=name: )\S+')
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
    # Simulate associative array lookup
    local module_index=-1
    for i in "${!module_map_keys[@]}"; do
      if [[ "${module_map_keys[$i]}" == "$module_name" ]]; then
        module_index="$i"
        break
      fi
    done

    if [[ "$module_index" -eq -1 ]]; then
      echo "Module $module_name not found." >&2
      return 1
    fi

    local module_path="${module_map_values[$module_index]}"

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

function detect_image_changes() {
  local base_dir=$1
  local use_last=$2
  echo "Base dir: ${base_dir}"

  read -r START_REF END_REF < <(get_commit_range "$use_last")
  echo "Start sha:${START_REF} - End: $END_REF"
  if [[ -z "$START_REF" || -z "$END_REF" ]]; then
    echo "Error: Unable to find two merge commits. Ensure there is enough merge history."
    exit 1
  fi

  build_module_map

  echo "----------------------------------------"
  echo "Module Map:"
  for i in "${!module_map_keys[@]}"; do # Iterate through the keys
    echo "Module: ${module_map_keys[$i]} => Path: ${module_map_values[$i]}"
  done
  echo "----------------------------------------"

  # Previous version of the script piped output directly into while loop BUT that effectively created a
  # sub-shell so when control returned to the function any changes to the variables were not visible
  # and the script always assumed nothing changed
  # Therefore capture file output to a temporary file and then consume that in the while loop, cleaning up
  # the temporary file afterwards
  find "$base_dir" -name "*.yaml" -print0 > .changed-descriptors

  while IFS= read -r -d $'\0' descriptor; do # Handles filenames with spaces
    debug_print "Checking image descriptor: $descriptor"
    if [ -z "$descriptor" ]; then
      continue
    fi

    if git diff --name-only "$END_REF" "$START_REF" | grep -q "$descriptor"; then
      echo "Image descriptor $descriptor has changed. Rebuild required."
      image_name=$(basename "$descriptor" | awk -F'.' '{print $1}')
      affected_images+=("$image_name")
    else
      if check_modules_in_image_descriptor "$descriptor"; then
        echo "Image $descriptor modules have changed. Rebuild required."
        image_name=$(basename "$descriptor" | awk -F'.' '{print $1}')
        affected_images+=("$image_name")
      fi
    fi
  done < .changed-descriptors
  rm -f .changed-descriptors

  if [[ ${#affected_images[@]} -gt 0 ]]; then
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

USE_LAST=""
if [[ "$1" == "use_last" ]]; then
  USE_LAST="use_last"
fi

detect_image_changes "image-descriptors" $USE_LAST
