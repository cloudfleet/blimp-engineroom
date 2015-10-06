#!/bin/bash
#
# CryptPart
# =========
#
# This scrypt formats, encrypts and sets for auto-mounting of a USB device.
# You need to provide the devie & key location in the set_partition_vars.sh script
#
# TODO:
# - get partition name from lsblk automatically
#
# sources:
#  - storage - http://xmodulo.com/how-to-create-encrypted-disk-partition-on-linux.html
#  - swap - https://help.ubuntu.com/community/EncryptedFilesystemHowto3
#  - swap 2 - http://unix.stackexchange.com/questions/64551/how-do-i-set-up-an-encrypted-swap-file-in-linux

DIR=$( cd "$( dirname $0 )" && pwd )
. $DIR/set_partition_vars.sh

# make sure the partition isn't already mounted
./close_partition.sh
cryptdisks_stop $STORAGE_PARTITION_LABEL

# noninteractive fdisk to partition the drive
./format_device.sh $STORAGE_DEVICE

# mount key device
mkdir -p $KEY_MOUNTPOINT
mount $KEY_DEVICE $KEY_MOUNTPOINT

# create key file
dd if=/dev/urandom of=$KEYFILE bs=1024 count=4
chmod 400 $KEYFILE

# encrypt storage partition
cryptsetup --verbose luksFormat $STORAGE_PARTITION - < $KEYFILE

# fill swap with 0s - takes ages & not sure if necessary in our case
# dd if=/dev/zero bs=1024000 of=$SWAP_PARTITION

# open partiotion (for elsewhere)
cryptsetup luksOpen $STORAGE_PARTITION $STORAGE_PARTITION_LABEL --key-file $KEYFILE

# format the swap
mkswap $SWAP_MAPPED_DEVICE

# format it to btrfs
apt-get install btrfs-tools # only once somewhere
mkfs.btrfs $STORAGE_MAPPED_DEVICE -L $STORAGE_PARTITION_LABEL

# start using the swap
swapon $SWAP_MAPPED_DEVICE

# mount the storage partition
mkdir -p $STORAGE_MOUNTPOINT
mount $STORAGE_MAPPED_DEVICE $STORAGE_MOUNTPOINT

# - decrypt and mount automatically on boot
./write_crypttab.sh
cryptdisks_start $SWAP_PARTITION_LABEL
cryptdisks_start $STORAGE_PARTITION_LABEL
./write_fstab.sh
mount -a

exit
