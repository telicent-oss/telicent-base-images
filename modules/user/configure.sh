#!/bin/bash
set -e
groupadd -r $USER -g $UID && useradd -u $UID -r -g root -G $USER -m -d $HOME -s /sbin/nologin -c "$GECOS" $USER

# OPENJDK-533, OPENJDK-556: correct permissions for OpenShift etc
chmod 0770 $HOME