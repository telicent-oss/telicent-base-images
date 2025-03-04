#!/bin/bash
set -e
env
microdnf -y module disable nginx
microdnf -y module enable nginx:$NGINX_VERSION
