#!/bin/bash
set -e
env
microdnf -y module disable nodejs
microdnf -y module enable nodejs:$NODEJS_VERSION