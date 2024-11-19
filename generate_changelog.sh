#!/bin/bash

#====================================================================================================
# Script to generate and append a changelog between two git tags or commits using Conventional Commit messages.
# Detects BREAKING CHANGES from the "!" in commit prefixes (e.g., fix!:, feat(sth)!:).
# Avoids appending multiple "Changelog" headers while preserving the file format.
# Filters out previous release PRs to keep the changelog clean.
#====================================================================================================

. ./git_diff.sh
read -r START_REF END_REF < <(get_commit_range)

commit_logs=$(git log --pretty=format:"%H %s" "$START_REF..$END_REF")

if [[ -z "$commit_logs" ]]; then
  echo "No commits found between $START_REF and $END_REF."
  exit 0
fi

declare -A categories=(
  ["feat"]="Features"
  ["fix"]="Fixes"
  ["chore"]="Chores"
  ["docs"]="Documentation"
  ["BREAKING"]="Breaking Changes"
)
declare -A changes_by_category

repo_url=$(git config --get remote.origin.url | sed -E 's/git@github.com:|https:\/\/github.com\///' | sed 's/\.git$//')

function process_commit {
  local commit_message="$1"
  local commit_hash="$2"
  local pr_number="$3"

  # Skip release PRs based on commit messages
  if echo "$commit_message" | grep -qE 'chore: prepare release v.* \(.*\)$'; then
    echo "Skipping release PR commit: $commit_message"
    return
  fi

  # Match commit prefixes (e.g., feat:, fix!:)
  prefix=$(echo "$commit_message" | grep -oE "^[a-zA-Z]+(\([^)]+\))?!?:")
  is_breaking=false

  # Check for breaking changes (indicated by "!")
  if [[ "$prefix" =~ !:$ ]]; then
    is_breaking=true
  fi

  if [[ -n "$prefix" ]]; then
    prefix=${prefix%%:*} # Remove the colon and extra characters
    local description="${commit_message#${prefix}: }"
    local category=""

    # Classify as breaking changes or assign to a regular category
    if [[ "$is_breaking" == true ]]; then
      category="BREAKING"
    else
      category="${categories[${prefix%%(*)}]:-Others}"
    fi

    # Create links for PRs and commits
    local pr_link=""
    if [[ -n "$pr_number" ]]; then
      pr_link="([#${pr_number}](https://github.com/${repo_url}/pull/${pr_number}))"
    fi
    commit_link="([${commit_hash:0:7}](https://github.com/${repo_url}/commit/${commit_hash}))"

    # Add to the changelog under the appropriate category
    changes_by_category["$category"]+="- ${description} ${pr_link} ${commit_link}\n"
  else
    # For non-conventional commits
    commit_link="([${commit_hash:0:7}](https://github.com/${repo_url}/commit/${commit_hash}))"
    changes_by_category["Others"]+="- ${commit_message} ${commit_link}\n"
  fi
}

# Process each commit
while IFS= read -r line; do
  commit_hash=$(echo "$line" | awk '{print $1}')
  commit_message=$(echo "$line" | cut -d' ' -f2-)
  pr_number=""

  # Detect if the commit is a merge request
  if [[ "$commit_message" =~ Merge\ pull\ request\ \#([0-9]+)\ from ]]; then
    pr_number="${BASH_REMATCH[1]}"
    pr_message=$(git show -s --format="%s" "$commit_hash")

    # Non-conventional PR commit message; get individual commits
    if ! echo "$pr_message" | grep -qE "^[a-zA-Z]+(\([^)]+\))?:"; then
      git log --pretty=format:"%H %s" "${commit_hash}^2..${commit_hash}^1" | while IFS= read -r pr_commit; do
        pr_commit_hash=$(echo "$pr_commit" | awk '{print $1}')
        pr_commit_message=$(echo "$pr_commit" | cut -d' ' -f2-)
        process_commit "$pr_commit_message" "$pr_commit_hash" "$pr_number"
      done
    else
      process_commit "$pr_message" "$commit_hash" "$pr_number"
    fi
  else
    process_commit "$commit_message" "$commit_hash" ""
  fi
done <<< "$commit_logs"

new_changelog="## Changes from $START_REF to $new_version\n\n"
for category in "${!categories[@]}"; do
  category_name="${categories[$category]}"
  if [[ -n "${changes_by_category[$category_name]}" ]]; then
    new_changelog+="### $category_name\n"
    new_changelog+=$(printf "%b" "${changes_by_category[$category_name]}")
    new_changelog+="\n"
  fi
done

if [[ -n "${changes_by_category["Others"]}" ]]; then
  new_changelog+="### Others\n"
  new_changelog+=$(printf "%b" "${changes_by_category["Others"]}")
  new_changelog+="\n"
fi

# Update the CHANGELOG.md
if [[ -f CHANGELOG.md ]]; then
  sed -i '1d' CHANGELOG.md # Remove existing header
  echo -e "# Changelog\n\n$new_changelog$(cat CHANGELOG.md)" > CHANGELOG.md
else
  echo -e "# Changelog\n\n$new_changelog" > CHANGELOG.md
fi

{
  echo "new_changelog<<EOF"
  echo -e "$new_changelog"
  echo "EOF"
} >> $GITHUB_ENV
