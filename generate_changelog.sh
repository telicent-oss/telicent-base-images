#!/bin/bash

LAST_TAG=${LAST_TAG:-$(git describe --tags --abbrev=0 HEAD^ || echo "v0.0.0")}

COMMITS=$(git log "$LAST_TAG"..HEAD --pretty=format:"%s (%h)")

echo "# Changelog"
echo
echo "## Changes from $LAST_TAG to $(git describe --tags HEAD || echo "unreleased")"
echo

FEATURES=$(echo "$COMMITS" | grep -E '^feat:' || true)
FIXES=$(echo "$COMMITS" | grep -E '^fix:' || true)
CHORES=$(echo "$COMMITS" | grep -E '^chore:' || true)
OTHERS=$(echo "$COMMITS" | grep -vE '^(feat:|fix:|chore:)' || true)

if [[ -n "$FEATURES" ]]; then
  echo "### Features"
  echo "$FEATURES" | sed -E 's/^feat: /- /'
  echo
fi

if [[ -n "$FIXES" ]]; then
  echo "### Fixes"
  echo "$FIXES" | sed -E 's/^fix: /- /'
  echo
fi

if [[ -n "$CHORES" ]]; then
  echo "### Chores"
  echo "$CHORES" | sed -E 's/^chore: /- /'
  echo
fi

if [[ -n "$OTHERS" ]]; then
  echo "### Others"
  echo "$OTHERS" | sed -E 's/^/- /'
  echo
fi
