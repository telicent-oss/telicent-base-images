#!/bin/bash

bump_version() {
  local version=$1
  local major minor patch

  IFS='.' read -r major minor patch <<< "$version"
  echo "$major.$minor.$((patch + 1))"
}

update_yaml_version() {
  local file=$1

  local current_version
  current_version=$(grep -E '^\s*version:.*&version' "$file" | sed -E 's/^.*&version "([^"]+)".*$/\1/')

  if [[ -z "$current_version" ]]; then
    echo "No version found in $file, skipping."
    return
  fi

  local new_version
  new_version=$(bump_version "$current_version")

  echo "Updating version in $file: $current_version -> $new_version"
  sed -i.bak -E "s/(^\s*version:.*&version) \"$current_version\"/\1 \"$new_version\"/" "$file" && rm -f "${file}.bak"
}

if [[ $# -eq 0 ]]; then
  echo "Usage: $0 <file1.yaml> [file2.yaml ...]"
  exit 1
fi

for yaml_file in "$@"; do
  if [[ -f "$yaml_file" ]]; then
    update_yaml_version "$yaml_file"
  else
    echo "File not found: $yaml_file"
  fi
done
