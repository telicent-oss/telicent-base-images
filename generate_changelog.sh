#!/bin/bash

#====================================================================================================
# Script to generate a changelog between two git tags or commits using Conventional Commit messages.
# Extracts from both merge events and commits, there could be bugs
#====================================================================================================

. ./git_diff.sh
read -r START_REF END_REF < <(get_commit_range)

echo "start-ref: ${START_REF} end-ref: ${END_REF}"

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
)
declare -A changes_by_category

# dynamically get the repo url
repo_url=$(git config --get remote.origin.url | sed -E 's/git@github.com:|https:\/\/github.com\///' | sed 's/\.git$//')

function process_commit {
  local commit_message="$1"
  local commit_hash="$2"
  local pr_number="$3"

  # Match conventional commit prefixes using grep, match fix: or fix(something):
  prefix=$(echo "$commit_message" | grep -oE "^[a-zA-Z]+(\([^)]+\))?:")
  if [[ -n "$prefix" ]]; then
    prefix=${prefix%%:*} # clear up the prefiz
    local description="${commit_message#${prefix}: }"
    local category="${categories[${prefix%%(*)}]:-Others}" # prepare the category
    local pr_link=""

    if [[ -n "$pr_number" ]]; then
      pr_link="([#${pr_number}](https://github.com/${repo_url}/pull/${pr_number}))"
    fi

    commit_link="([${commit_hash:0:7}](https://github.com/${repo_url}/commit/${commit_hash}))"

    changes_by_category["$category"]+="- ${description} ${pr_link} ${commit_link}\n"
  else
    # add non concentional commits in case people are naughty
    commit_link="([${commit_hash:0:7}](https://github.com/${repo_url}/commit/${commit_hash}))"
    changes_by_category["Others"]+="- ${commit_message} ${commit_link}\n"
  fi
}

while IFS= read -r line; do
  commit_hash=$(echo "$line" | awk '{print $1}')
  commit_message=$(echo "$line" | cut -d' ' -f2-)
  pr_number=""

  # is it a merge request ?
  if [[ "$commit_message" =~ Merge\ pull\ request\ \#([0-9]+)\ from ]]; then
    pr_number="${BASH_REMATCH[1]}"
    pr_message=$(git show -s --format="%s" "$commit_hash")

    # non conventional pr commit message try get it from the commits in the PR
    if ! echo "$pr_message" | grep -qE "^[a-zA-Z]+(\([^)]+\))?:"; then
      # process commits in pr individually
      git log --pretty=format:"%H %s" "${commit_hash}^2..${commit_hash}^1" | while IFS= read -r pr_commit; do
        pr_commit_hash=$(echo "$pr_commit" | awk '{print $1}')
        pr_commit_message=$(echo "$pr_commit" | cut -d' ' -f2-)
        process_commit "$pr_commit_message" "$pr_commit_hash" "$pr_number"
      done
    else
      # process the PR message directly
      process_commit "$pr_message" "$commit_hash" "$pr_number"
    fi
  else
    # process regular commits
    process_commit "$commit_message" "$commit_hash" ""
  fi
done <<< "$commit_logs"

echo "# Changelog"
echo
echo "## Changes from $START_REF to $END_REF"
echo

# print the changes by iterating over categories
for category in "${!categories[@]}"; do
  category_name="${categories[$category]}"
  if [[ -n "${changes_by_category[$category_name]}" ]]; then
    echo "### $category_name"
    printf "%b" "${changes_by_category[$category_name]}"
    echo
  fi
done

# finally add the uncategorised
if [[ -n "${changes_by_category["Others"]}" ]]; then
  echo "### Others"
  printf "%b" "${changes_by_category["Others"]}"
  echo
fi
