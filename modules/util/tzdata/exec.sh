#!/bin/bash
set -e
microdnf reinstall tzdata -y && microdnf -y clean all
