#!/bin/bash

#====================================================================================================
# Script to generate a changelog between two git tags or commits using Conventional Commit messages.
# It dynamically links to pull requests and categorizes changes into Features, Fixes, and Others.
#====================================================================================================

. ./get_diff.sh
read -r START_REF END_REF < <(get_commit_range)

START_REF=$1
END_REF=$2

# Fetch commit logs
commit_logs=$(git log --pretty=format:"%H %s" --merges "$START_REF..$END_REF")

if [[ -z "$commit_logs" ]]; then
  echo "No commits found between $START_REF and $END_REF."
  exit 0
fi

features=()
fixes=()
chores=()
others=()

repo_url=$(git config --get remote.origin.url | sed -E 's/git@github.com:|https:\/\/github.com\///' | sed 's/\.git$//')

# Process each merge commit
while IFS= read -r line; do
  commit_hash=$(echo "$line" | awk '{print $1}')
  commit_message=$(echo "$line" | cut -d' ' -f2-)

  # Extract PR number (if available) and append a link
  if [[ "$commit_message" =~ \(#([0-9]+)\) ]]; then
    pr_number="${BASH_REMATCH[1]}"
    pr_link="([#${pr_number}](https://github.com/${repo_url}/pull/${pr_number}))"
  else
    pr_link=""
  fi

  if [[ "$commit_message" =~ ^feat: ]]; then
    features+=("- ${commit_message} ${pr_link}")
  elif [[ "$commit_message" =~ ^fix: ]]; then
    fixes+=("- ${commit_message} ${pr_link}")
  elif [[ "$commit_message" =~ ^chore: ]]; then
    chores+=("- ${commit_message} ${pr_link}")
  else
    others+=("- ${commit_message} ${pr_link}")
  fi
done <<< "$commit_logs"

# Generate changelog
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

if [[ ${#others[@]} -gt 0 ]]; then
  echo "### Others"
  printf "%s\n" "${others[@]}"
  echo
fi
