#!/bin/bash

# source: http://xmodulo.com/how-to-create-encrypted-disk-partition-on-linux.html

DIR=$( cd "$( dirname $0 )" && pwd )
. $DIR/set_partition_vars.sh

# make sure the partition isn't already mounted
./close_partition.sh
cryptdisks_stop sda1

# noninteractive fdisk to partition the drive
./format_device.sh $STORAGE_DEVICE

# TODO:
# - get partition name from lsblk
# - do stuff for both created partitions (swap and storage)

# create key file
# TODO: see where this should be done really and find a good place for the file
dd if=/dev/urandom of=$KEYFILE bs=1024 count=4
chmod 400 $KEYFILE

cryptsetup --verbose luksFormat $STORAGE_PARTITION - < $KEYFILE

# open partiotion (for elsewhere)
cryptsetup luksOpen $STORAGE_PARTITION $STORAGE_PARTITION_LABEL --key-file $KEYFILE

# format it to btrfs
apt-get install btrfs-tools # only once somewhere
mkfs.btrfs $STORAGE_MAPPED_DEVICE -L cloudfleet-storage

# mount the storage partition
mkdir -p $STORAGE_MOUNTPOINT
mount $STORAGE_MAPPED_DEVICE $STORAGE_MOUNTPOINT

./write_crypttab.sh
cryptdisks_start sda1

# TODO:
# - create keyfile

# - decrypt and mount automatically on boot

exit
