#!/bin/bash

#====================================================================================================
# Script to generate and append a changelog between two git tags or commits using Conventional Commit messages.
# Extracts from both merge events and commits, appends to an existing CHANGELOG.md while preserving the current logic.
# Detects BREAKING CHANGES from the "!" in commit prefixes (e.g., fix!:, feat(sth)!:).
#====================================================================================================

. ./git_diff.sh
read -r START_REF END_REF < <(get_commit_range)

commit_logs=$(git log --pretty=format:"%H %s" "$START_REF..$END_REF")

if [[ -z "$commit_logs" ]]; then
  echo "No commits found between $START_REF and $END_REF."
  exit 0
fi

# These are the conventional commits we'd be looking out for
declare -A categories=(
  ["feat"]="Features"
  ["fix"]="Fixes"
  ["chore"]="Chores"
  ["docs"]="Documentation"
  ["BREAKING"]="Breaking Changes"
)
declare -A changes_by_category

# Dynamically get the repo URL
repo_url=$(git config --get remote.origin.url | sed -E 's/git@github.com:|https:\/\/github.com\///' | sed 's/\.git$//')

function process_commit {
  local commit_message="$1"
  local commit_hash="$2"
  local pr_number="$3"

  # Match conventional commit prefixes using grep, match fix: or fix(something)!:
  prefix=$(echo "$commit_message" | grep -oE "^[a-zA-Z]+(\([^)]+\))?!?:")
  is_breaking=false

  # Check if the prefix contains an exclamation mark '!' before the colon
  if [[ "$prefix" =~ !:$ ]]; then
    is_breaking=true
  fi

  if [[ -n "$prefix" ]]; then
    prefix=${prefix%%:*} # Clear up the prefix
    local description="${commit_message#${prefix}: }"
    local category=""

    if [[ "$is_breaking" == true ]]; then
      category="BREAKING"
    else
      category="${categories[${prefix%%(*)}]:-Others}" # Prepare the category
    fi

    local pr_link=""
    if [[ -n "$pr_number" ]]; then
      pr_link="([#${pr_number}](https://github.com/${repo_url}/pull/${pr_number}))"
    fi

    commit_link="([${commit_hash:0:7}](https://github.com/${repo_url}/commit/${commit_hash}))"

    changes_by_category["$category"]+="- ${description} ${pr_link} ${commit_link}\n"
  else
    # Add non-conventional commits in case people are naughty
    commit_link="([${commit_hash:0:7}](https://github.com/${repo_url}/commit/${commit_hash}))"
    changes_by_category["Others"]+="- ${commit_message} ${commit_link}\n"
  fi
}

while IFS= read -r line; do
  commit_hash=$(echo "$line" | awk '{print $1}')
  commit_message=$(echo "$line" | cut -d' ' -f2-)
  pr_number=""

  # Is it a merge request?
  if [[ "$commit_message" =~ Merge\ pull\ request\ \#([0-9]+)\ from ]]; then
    pr_number="${BASH_REMATCH[1]}"
    pr_message=$(git show -s --format="%s" "$commit_hash")

    # Non-conventional PR commit message; try getting it from the commits in the PR
    if ! echo "$pr_message" | grep -qE "^[a-zA-Z]+(\([^)]+\))?:"; then
      # Process commits in PR individually
      git log --pretty=format:"%H %s" "${commit_hash}^2..${commit_hash}^1" | while IFS= read -r pr_commit; do
        pr_commit_hash=$(echo "$pr_commit" | awk '{print $1}')
        pr_commit_message=$(echo "$pr_commit" | cut -d' ' -f2-)
        process_commit "$pr_commit_message" "$pr_commit_hash" "$pr_number"
      done
    else
      # Process the PR message directly
      process_commit "$pr_message" "$commit_hash" "$pr_number"
    fi
  else
    # Process regular commits
    process_commit "$commit_message" "$commit_hash" ""
  fi
done <<< "$commit_logs"

# Prepare the new changelog content, $new_version comes from gh action env
new_changelog="## Changes from $START_REF to $new_version \n----\n"

# Print the changes by iterating over categories
for category in "${!categories[@]}"; do
  category_name="${categories[$category]}"
  if [[ -n "${changes_by_category[$category_name]}" ]]; then
    new_changelog+="### $category_name\n"
    new_changelog+=$(printf "%b" "${changes_by_category[$category_name]}")
    new_changelog+="\n"
  fi
done

# Finally add the uncategorized
if [[ -n "${changes_by_category["Others"]}" ]]; then
  new_changelog+="### Others\n"
  new_changelog+=$(printf "%b" "${changes_by_category["Others"]}")
  new_changelog+="\n\n"
fi

if [[ -f CHANGELOG.md ]]; then
  sed -i '1d' CHANGELOG.md # Remove the existing header
  echo -e "# Changelog\n\n$new_changelog$(cat CHANGELOG.md)" > CHANGELOG.md
else
  echo -e "# Changelog\n\n$new_changelog" > CHANGELOG.md
fi

echo "new_changelog=${new_changelog}" >> $GITHUB_OUTPUT
