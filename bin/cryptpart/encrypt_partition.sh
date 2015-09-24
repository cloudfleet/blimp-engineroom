#!/bin/bash

# source: http://xmodulo.com/how-to-create-encrypted-disk-partition-on-linux.html

# TODO - find where the usb drive is via lsblk, label or something.
STORAGE_DEVICE=/dev/sda
STORAGE_PARTITION=/dev/sda1
STORAGE_PARTITION_LABEL=sda1
STORAGE_MAPPED_DEVICE=/dev/mapper/$STORAGE_PARTITION_LABEL
STORAGE_MOUNTPOINT=/mnt

# TODO - noninteractive fdisk to partition the drive
# fdisk $STORAGE_DEVICE

# TODO:
# - make noninteractive
# - get partition name from lsblk
cryptsetup --verbose --verify-passphrase luksFormat $STORAGE_PARTITION

# open partiotion (for elsewhere)
# cryptsetup luksOpen $STORAGE_PARTITION $STORAGE_PARTITION_LABEL

# format it to btrfs
apt-get install btrfs-tools # only once somewhere
mkfs.btrfs $STORAGE_MAPPED_DEVICE

# mount the storage partition
mount $STORAGE_MAPPED_DEVICE $STORAGE_MOUNTPOINT

# TODO:
# - create keyfile
# - decrypt and mount automatically on boot

exit
