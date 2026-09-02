#!/bin/sh
# Remount / rw if it is ro and the superblock says clean.

set -u

findmnt -no OPTIONS / | tr ',' '\n' | grep -qx ro || exit 0

DEV=$(findmnt -no SOURCE /)

if dumpe2fs -h "$DEV" 2>/dev/null | grep -q '^Filesystem state: *clean$'; then
    logger -t root-remount "/ ro but clean - remounting rw"
    mount -o remount,rw /
elif dumpe2fs -h "$DEV" 2>/dev/null | grep -q '^Filesystem state: *not clean$'; then
    logger -p daemon.crit -t root-remount "/ ro and not clean - fsck required"
    exit 1
else
    logger -p daemon.info -t root-remount "/ already rw, no action taken"
fi
