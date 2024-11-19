function get_commit_range() {
  # Get the most recent tag in the repository, sorted by creation date
  local last_tag=$(git tag --sort=-creatordate | head -n 1)

  if [[ -z "$last_tag" ]]; then
    # No tags exist; use the first commit as the start point
    echo "$(git rev-list --max-parents=0 HEAD) HEAD"
  else
    # Use the last tag as the start point
    echo "$last_tag HEAD"
  fi
}