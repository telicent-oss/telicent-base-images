function get_commit_range() {
  # Get the most recent tag in the repository, sorted by creation date
  tags=($(git tag --sort=-creatordate | head -n 2))

  # In case where there are many tags pick the second last one and
  # compare it to head which can be a tag or a repo
  if [[ ${#tags[@]} -ge 2 ]]; then
    last_tag="${tags[1]}" # Pick the second most recent tag
    echo "$last_tag HEAD"
  else
    # Generally, everything else compare from base of the repo, as soon
    # there are 2 tags this will never execute anyway
    echo "$(git rev-list --max-parents=0 HEAD) HEAD"
  fi
}