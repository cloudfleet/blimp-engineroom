#!/bin/bash

DIR=$( cd "$( dirname $0 )" && pwd )
. $DIR/set_partition_vars.sh

if [ -f /etc/fstab.original ]
then
    # we already made a copy of the first fstab
    :
else
    # make a copy of the first fstab
    # (we will only do this once)
    cp /etc/fstab /etc/fstab.original
fi

# make sure the mount points exist
mkdir -p $KEY_MOUNTPOINT
mkdir -p $STORAGE_MOUNTPOINT

# create the new /etc/fstab file
cp /etc/fstab.original /etc/fstab
echo "${KEY_PARTITION} ${KEY_MOUNTPOINT} auto defaults 0 0
${SWAP_MAPPED_DEVICE} none swap pri=1,defaults 0 0
${STORAGE_MAPPED_DEVICE} ${STORAGE_MOUNTPOINT} btrfs" >> /etc/fstab
