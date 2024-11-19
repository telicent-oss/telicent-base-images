#!/bin/bash

#====================================================================================================
# Script to determine the next semantic version based on commit messages between the last tag (or first commit)
# and HEAD. Detects breaking changes, features, and patches using Conventional Commit patterns.
#====================================================================================================

trim_whitespace() {
  echo "$1" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//'
}

echo "Determining the starting reference..."
LAST_TAG=$(git describe --tags --abbrev=0 2>/dev/null || echo "")

if [[ -z "$LAST_TAG" ]]; then
  START_REF=$(git rev-list --max-parents=0 HEAD) # First commit
  echo "No tags found. Using the first commit ($START_REF) as START_REF."
else
  START_REF="$LAST_TAG"
  echo "Found last tag: $LAST_TAG (START_REF=$START_REF)."
fi

if [[ -z "$LAST_TAG" ]]; then
  MAJOR=0
  MINOR=0
  PATCH=0
else
  VERSION_PARTS=($(echo "${LAST_TAG//v/}" | tr '.' ' '))
  MAJOR=${VERSION_PARTS[0]:-0}
  MINOR=${VERSION_PARTS[1]:-0}
  PATCH=${VERSION_PARTS[2]:-0}
fi

BUMP_MAJOR=false
BUMP_MINOR=false
BUMP_PATCH=false

# debugging output for initial state
echo "Initial Version: v${MAJOR}.${MINOR}.${PATCH}"
echo "Analyzing commits between $START_REF and HEAD..."

# Step 3: Analyze commit messages
commit_messages=$(git log "$START_REF"..HEAD --pretty=format:"%s")

while IFS= read -r line; do
  # Trim whitespace from the commit message
  line=$(trim_whitespace "$line")

  # Debugging each commit message
  echo "Processing commit message: '$line'"

  # check for breaking changes (explicit or with `!` suffix)
  if echo "$line" | grep -qE "(BREAKING CHANGE|!:|^.*!:)" ; then
    BUMP_MAJOR=true
  # check for features (e.g., feat:, feat(scope):, feat!:)
  elif echo "$line" | grep -qE "^feat(\(.*\))?!?:"; then
    BUMP_MINOR=true
  # check for fixes, chores, and other non-major updates (e.g., fix:, fix(scope):, fix!:, chore:, chore!:)
  elif echo "$line" | grep -qE "^(fix|chore)(\(.*\))?!?:"; then
    BUMP_PATCH=true
  fi
done <<< "$commit_messages"

echo "Calculating the new version..."
if [[ "$BUMP_MAJOR" == true ]]; then
  MAJOR=$((MAJOR + 1))
  MINOR=0
  PATCH=0
elif [[ "$BUMP_MINOR" == true ]]; then
  MINOR=$((MINOR + 1))
  PATCH=0
elif [[ "$BUMP_PATCH" == true ]]; then
  PATCH=$((PATCH + 1))
else
  echo "No relevant changes found. Version remains unchanged."
  NEW_VERSION="v${MAJOR}.${MINOR}.${PATCH}"
  echo "new_version=$NEW_VERSION" >> $GITHUB_OUTPUT
  exit 0
fi

NEW_VERSION="v${MAJOR}.${MINOR}.${PATCH}"

echo "New version: $NEW_VERSION"

echo "new_version=$NEW_VERSION" >> $GITHUB_ENV
echo "new_version=$NEW_VERSION" >> $GITHUB_OUTPUT
