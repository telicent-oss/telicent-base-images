#!/bin/bash

# Verify the npm CLI is absent from a built image.
#
# Why: npm ships as files inside the nodejs rpm (there is no separate npm
# package), and the telicent.container.util.cleanup.npm module removes it
# (rm -rf /usr/lib/node_modules/npm) to cut CVE surface area — e.g. the
# brace-expansion DoS CVE-2026-13149 lives only in npm's bundled deps. This
# check proves that removal actually held in the shipped image. The node
# binary itself must remain present and working.
#
# Usage: ./check_no_npm.sh [IMAGE]
#   IMAGE : image ref to check (default: telicent/telicent-nodejs22:latest)
#
# Exit codes: 0 = npm absent (pass), 1 = npm present or node missing (fail).

set -euo pipefail

IMAGE="${1:-telicent/telicent-nodejs22:latest}"

echo "Checking npm is absent from: $IMAGE"

# Probe the image in one container invocation. Prints a line per fact so the
# result is auditable in CI logs, then a final PASS/FAIL sentinel.
RESULT=$(docker run --rm --entrypoint sh "$IMAGE" -c '
  fail=0
  if command -v node >/dev/null 2>&1; then
    echo "node: present ($(node --version))"
  else
    echo "node: ABSENT (unexpected)"
    fail=1
  fi
  for bin in npm npx; do
    if command -v "$bin" >/dev/null 2>&1; then
      echo "$bin: PRESENT at $(command -v "$bin") (should be removed)"
      fail=1
    else
      echo "$bin: absent"
    fi
  done
  if [ -d /usr/lib/node_modules/npm ]; then
    echo "npm module dir: PRESENT at /usr/lib/node_modules/npm (should be removed)"
    fail=1
  else
    echo "npm module dir: absent"
  fi
  [ "$fail" -eq 0 ] && echo "SENTINEL=PASS" || echo "SENTINEL=FAIL"
')

echo "$RESULT"

if echo "$RESULT" | grep -q "SENTINEL=PASS"; then
  echo "PASS: npm is absent from $IMAGE"
  exit 0
fi

echo "FAIL: npm (or node) check failed for $IMAGE"
exit 1
