#!/bin/bash

function get_commit_range() {
  local last_tag=$(git describe --tags --abbrev=0 HEAD 2>/dev/null || echo "")
  local last_tag_sha=$(git rev-list -n 1 "$last_tag" 2>/dev/null || echo "")

  if [[ -z "$last_tag_sha" ]]; then
    echo "$(git rev-list --max-parents=0 HEAD) HEAD"
    return
  fi

  # Compare the last tag with the current HEAD
  echo "$last_tag HEAD"
}