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
# noauto only necessary because systemd doesn't recognise keyscript
# (not really needed on the Cubox)
echo "${KEY_PARTITION} ${KEY_MOUNTPOINT} auto defaults 0 0
${SWAP_MAPPED_DEVICE} none swap pri=1,defaults 0 0
${STORAGE_MAPPED_DEVICE} ${STORAGE_MOUNTPOINT} btrfs defaults,noauto 0 0
${STORAGE_MAPPED_DEVICE} ${CLOUDFLEET_DATA_PATH} btrfs defaults,subvol=data,noauto 0 0
${STORAGE_MAPPED_DEVICE} ${DOCKER_DATA_PATH} btrfs defaults,subvol=docker,noauto 0 0" >> /etc/fstab
