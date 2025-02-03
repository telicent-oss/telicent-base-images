#!/bin/bash
set -e
# todo -g might need reverted back to root for java
groupadd -r $USER -g $UID && useradd -u $UID -r -g $USER -G $USER -m -d $HOME -s /sbin/nologin -c "$GECOS" $USER

# OPENJDK-533, OPENJDK-556: correct permissions for OpenShift etc
chmod 0770 $HOME