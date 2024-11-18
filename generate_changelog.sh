#!/bin/bash

#====================================================================================================
# Script to generate a changelog between two git tags or commits using Conventional Commit messages.
# It includes both commits and merge requests that follow the conventional commit format.
#====================================================================================================

# Load commit range utility
. ./git_diff.sh
read -r START_REF END_REF < <(get_commit_range)

echo "start-ref: ${START_REF} end-ref: ${END_REF}"

# Fetch all relevant logs (commits + merge commits)
commit_logs=$(git log --pretty=format:"%H %s" "$START_REF..$END_REF")

if [[ -z "$commit_logs" ]]; then
  echo "No commits found between $START_REF and $END_REF."
  exit 0
fi

# Initialize changelog categories
features=()
fixes=()
chores=()
docs=()
others=()

# Extract repository URL dynamically
repo_url=$(git config --get remote.origin.url | sed -E 's/git@github.com:|https:\/\/github.com\///' | sed 's/\.git$//')

# Process each commit and merge request
while IFS= read -r line; do
  commit_hash=$(echo "$line" | awk '{print $1}')
  commit_message=$(echo "$line" | cut -d' ' -f2-)

  # Check if the commit is a merge request and extract its PR number
  if [[ "$commit_message" =~ Merge\ pull\ request\ \#([0-9]+)\ from ]]; then
    pr_number="${BASH_REMATCH[1]}"
    pr_message=$(git show -s --format="%s" "$commit_hash")

    # Use the PR title if it follows conventional commits
    if [[ "$pr_message" =~ ^feat: ]]; then
      features+=("- ${pr_message#feat:} ([#${pr_number}](https://github.com/${repo_url}/pull/${pr_number}))")
    elif [[ "$pr_message" =~ ^fix: ]]; then
      fixes+=("- ${pr_message#fix:} ([#${pr_number}](https://github.com/${repo_url}/pull/${pr_number}))")
    elif [[ "$pr_message" =~ ^chore: ]]; then
      chores+=("- ${pr_message#chore:} ([#${pr_number}](https://github.com/${repo_url}/pull/${pr_number}))")
    elif [[ "$pr_message" =~ ^docs: ]]; then
      docs+=("- ${pr_message#docs:} ([#${pr_number}](https://github.com/${repo_url}/pull/${pr_number}))")
    else
      others+=("- ${pr_message} ([#${pr_number}](https://github.com/${repo_url}/pull/${pr_number}))")
    fi
  else
    # For regular commits, categorize them based on the conventional commit prefixes
    if [[ "$commit_message" =~ ^feat: ]]; then
      features+=("- ${commit_message#feat:}")
    elif [[ "$commit_message" =~ ^fix: ]]; then
      fixes+=("- ${commit_message#fix:}")
    elif [[ "$commit_message" =~ ^chore: ]]; then
      chores+=("- ${commit_message#chore:}")
    elif [[ "$commit_message" =~ ^docs: ]]; then
      docs+=("- ${commit_message#docs:}")
    else
      others+=("- ${commit_message}")
    fi
  fi
done <<< "$commit_logs"

# Generate the changelog
echo "# Changelog"
echo
echo "## Changes from $START_REF to $END_REF"
echo

if [[ ${#features[@]} -gt 0 ]]; then
  echo "### Features"
  printf "%s\n" "${features[@]}"
  echo
fi

if [[ ${#fixes[@]} -gt 0 ]]; then
  echo "### Fixes"
  printf "%s\n" "${fixes[@]}"
  echo
fi

if [[ ${#chores[@]} -gt 0 ]]; then
  echo "### Chores"
  printf "%s\n" "${chores[@]}"
  echo
fi

if [[ ${#docs[@]} -gt 0 ]]; then
  echo "### Documentation"
  printf "%s\n" "${docs[@]}"
  echo
fi

if [[ ${#others[@]} -gt 0 ]]; then
  echo "### Others"
  printf "%s\n" "${others[@]}"
  echo
fi
