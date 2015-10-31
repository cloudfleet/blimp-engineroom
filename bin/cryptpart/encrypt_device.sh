#!/bin/bash
#
# CryptPart
# =========
#
# This scrypt formats, encrypts and sets for auto-mounting of a USB storage and a USB key device.
#
# You need to provide two USBs that contain partitions with key and storage labels
# from the set_partition_vars.sh script. Ideally, cf-key will be ext3, ext4 or similar,
# so that we can set file permissions. FAT would work too, though.
#
# E.g.
#
# USB 1 - 1 partition labeled cf-str
# USB 2 - 1 partition labeled cf-key
#
#
# sources:
#  - storage - http://xmodulo.com/how-to-create-encrypted-disk-partition-on-linux.html
#  - swap - https://help.ubuntu.com/community/EncryptedFilesystemHowto3
#  - swap 2 - http://unix.stackexchange.com/questions/64551/how-do-i-set-up-an-encrypted-swap-file-in-linux
#  - btrfs - https://wiki.archlinux.org/index.php/Btrfs
#  - btrfs 2 - http://unix.stackexchange.com/questions/190698/btrfs-mounting-a-subvolume-in-a-different-path-does-not-work-no-such-file-or

# TODO:
# - retry
# - name devices by uuid, not by sda/sdb in fstab (blkid /dev/sda1)
# - mount key before running /etc/crypttab

echo "====================================="
echo "`date "+%F %T"`  Encrypting storage if necessary & possible ... "
echo "====================================="

DIR=$( cd "$( dirname $0 )" && pwd )
. $DIR/set_partition_vars.sh
# -> after this first run, we expect $STORAGE_DEVICE to be something like "/dev/sda" or ""

if [ -z "$STORAGE_DEVICE" ]; then
    tput setaf 1; echo "No storage device marked by partition label or LUKS partition label ${STORAGE_PARTITION_LABEL}. Quitting encryption."; tput sgr0
    exit 1
fi

if [ -z "$KEY_PARTITION" ]; then
    tput setaf 1; echo "No key partition marked by label ${KEY_PARTITION_LABEL}. Quitting encryption."; tput sgr0
    exit 1
fi

# get partition name from lsblk automatically and check the partitions
lsblk | $DIR/check_partitions.py

if [ $? -eq 0 ]; then
    echo "Partitions already encrypted. Not formatting"
    exit
fi

echo "Partitions not encrypted. Formatting now!"

# make sure the partition isn't already mounted
$DIR/close_partition.sh

# noninteractive fdisk to partition the drive
$DIR/format_device.sh $STORAGE_DEVICE

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
cryptsetup open $STORAGE_PARTITION $STORAGE_PARTITION_LABEL --key-file $KEYFILE

# format the swap
#mkswap $SWAP_MAPPED_DEVICE
mkswap $SWAP_PARTITION

# format it to btrfs
apt-get install btrfs-tools # only once somewhere
mkfs.btrfs $STORAGE_MAPPED_DEVICE -L $STORAGE_PARTITION_LABEL

# exit # early for debug purposes

# mount the storage partition
mkdir -p $STORAGE_MOUNTPOINT
mount $STORAGE_MAPPED_DEVICE $STORAGE_MOUNTPOINT

# - decrypt and mount automatically on boot
# TODO: parse the UUIDs, write them to crypttab and use UUIDs from now on
$DIR/write_crypttab.sh
cryptdisks_start $SWAP_PARTITION_LABEL
cryptdisks_start $STORAGE_PARTITION_LABEL
$DIR/write_fstab.sh
mount -a

# start using the swap
swapon $SWAP_MAPPED_DEVICE

$DIR/create_btrfs_partitions.sh

exit
