#!/bin/bash
set -e
microdnf -y module disable nodejs
microdnf -y module enable nodejs:$NODEJS_VERSION
