#!/bin/bash
set -euo pipefail

if microdnf --enablerepo=ubi-9-appstream-rpms install -y sysstat; then
  :
else
  echo "WARN: sysstat not available; enable ubi-9-appstream-rpms or install on the host." >&2
fi

if microdnf --enablerepo=ubi-9-codeready-builder-rpms install -y kernel-tools; then
  :
else
  echo "WARN: kernel-tools (perf) not available; enable ubi-9-codeready-builder-rpms or use host perf." >&2
fi

microdnf clean all
