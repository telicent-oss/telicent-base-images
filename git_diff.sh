#!/bin/bash

function get_commit_range() {
  local last_tag=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

  if [[ -z "$last_tag" ]]; then
    # No tags exist; compare from the first commit to HEAD
    echo "$(git rev-list --max-parents=0 HEAD) HEAD"
    return
  fi

  # Get the previous tag
  local previous_tag=$(git describe --tags --abbrev=0 "${last_tag}^" 2>/dev/null || echo "")

  if [[ -z "$previous_tag" ]]; then
    # No previous tag; compare from the last tag to HEAD
    echo "$last_tag HEAD"
  else
    # Compare between the previous and the last tag
    echo "$previous_tag $last_tag"
  fi
}