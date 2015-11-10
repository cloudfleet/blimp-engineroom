#!/bin/bash

# keyscript called from /etc/crypttab to mount the key USB and echo the key
# make sure the key is mounted before accessing it
#
# usage:
# ./keyscript.sh <key_partition>

set -e

# not setting these using ./set_partition_vars.sh to reduce the number of dependencies
# (as this script is called early in the boot process)
KEY_PARTITION=$1
KEY_MOUNTPOINT=/mnt/storage-key

if mountpoint -q "$KEY_MOUNTPOINT"; then
    : # already mounted, do nothing
else
    mount -t auto $KEY_PARTITION $KEY_MOUNTPOINT
fi

cat /mnt/storage-key/key
