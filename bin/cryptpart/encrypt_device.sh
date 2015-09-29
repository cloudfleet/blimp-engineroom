#!/bin/bash

# source: http://xmodulo.com/how-to-create-encrypted-disk-partition-on-linux.html

DIR=$( cd "$( dirname $0 )" && pwd )
. $DIR/set_partition_vars.sh

# make sure the partition isn't already mounted
./close_partition.sh

# TODO - noninteractive fdisk to partition the drive
# fdisk $STORAGE_DEVICE
./format_device.sh $STORAGE_DEVICE

# TODO:
# - make noninteractive
# - get partition name from lsblk
cryptsetup --verbose --verify-passphrase luksFormat $STORAGE_PARTITION

# open partiotion (for elsewhere)
cryptsetup luksOpen $STORAGE_PARTITION $STORAGE_PARTITION_LABEL

# format it to btrfs
apt-get install btrfs-tools # only once somewhere
mkfs.btrfs $STORAGE_MAPPED_DEVICE

# mount the storage partition
mkdir -p $STORAGE_MOUNTPOINT
mount $STORAGE_MAPPED_DEVICE $STORAGE_MOUNTPOINT

# TODO:
# - create keyfile

# - decrypt and mount automatically on boot

exit
