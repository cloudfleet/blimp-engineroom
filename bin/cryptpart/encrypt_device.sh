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
# sources:
#
#  - storage - http://xmodulo.com/how-to-create-encrypted-disk-partition-on-linux.html
#  - batch mode - https://github.com/debops-contrib/ansible-cryptsetup
#  - swap - https://help.ubuntu.com/community/EncryptedFilesystemHowto3
#  - swap 2 - http://unix.stackexchange.com/questions/64551/how-do-i-set-up-an-encrypted-swap-file-in-linux
#  - btrfs - https://wiki.archlinux.org/index.php/Btrfs
#  - btrfs 2 - http://unix.stackexchange.com/questions/190698/btrfs-mounting-a-subvolume-in-a-different-path-does-not-work-no-such-file-or
#  - key on external device & keyscripts
#    - http://stackoverflow.com/questions/19713918/how-to-load-luks-passphrase-from-usb-falling-back-to-keyboard
#    - http://binblog.info/2008/12/04/using-a-usb-key-for-the-luks-passphrase/
#    - http://www.gaztronics.net/howtos/luks.php
#    - http://possiblelossofprecision.net/?p=300
#    - http://www.oxygenimpaired.com/debian-lenny-luks-encrypted-root-hidden-usb-keyfile
#  - keyscript workaround for Systemd
#    - http://gw.tnode.com/debian/issues-and-workarounds-for-debian-8/
#  - some Arch wiki ground knowledge on the topic:
#    - https://wiki.archlinux.org/index.php/Dm-crypt/Swap_encryption
#    - https://wiki.archlinux.org/index.php/Dm-crypt/Device_encryption#With_a_keyfile_stored_on_an_external_media
#    - https://wiki.archlinux.org/index.php/Persistent_block_device_naming


# TODO:
#
# - make initial disk labels uppercase for better Win support
# - automatically add missing kernel module on Cubox
# - make sure /mnt/storage-key is unmounted sometime after boot normally & additionally after this script
# - retry from a clean state & see that it works after reboot

echo "====================================="
echo "`date "+%F %T"`  Encrypting storage if necessary & possible ... "
echo "====================================="

echo " - set variables (we only care about the device here - partitions will be wrong)"
DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "Installing cryptsetup"

. $DIR/set_partition_vars.sh
# -> after this first run, we expect $STORAGE_DEVICE to be something like "/dev/sda" or ""

if [ -z "$KEY_PARTITION" ]; then
    tput setaf 1; echo "No key partition marked by label ${KEY_PARTITION_LABEL}. Quitting encryption."; tput sgr0
    exit 1
fi

# get partition name from lsblk automatically and check the partitions
lsblk --pairs | $DIR/check_partitions.py

if [ $? -eq 0 ]; then
    echo "Partitions either already encrypted or not ready for formating. Exiting from cryptpart."
    exit
fi

if [ -z "$STORAGE_DEVICE" ]; then
    tput setaf 1; echo "No storage device marked by partition label or LUKS partition label ${STORAGE_PARTITION_LABEL}. Quitting encryption."; tput sgr0
    exit 1
fi

echo "Partitions not encrypted. Formatting now!"

# make sure the partition isn't already mounted
echo " - close partitions"
$DIR/close_partition.sh

# disable automatic docker service starting
# (necessary because systemd doesn't parse keyscript)
systemctl disable docker.service

# noninteractive fdisk to partition the drive
echo " - format device"
$DIR/format_device.sh $STORAGE_DEVICE

STORAGE_PARTITION="${STORAGE_DEVICE}1"

echo "mount key device"
mkdir -p $KEY_MOUNTPOINT
mount -t auto $KEY_PARTITION $KEY_MOUNTPOINT

echo "create key file"
echo " - write random key"
dd if=/dev/urandom of=$KEYFILE bs=1024 count=4
chmod 400 $KEYFILE

# encrypt storage partition
echo " - encrypt storage partition"
# this seems to be wrong - maybe it's interpreted as a passphrase
#cryptsetup --verbose luksFormat $STORAGE_PARTITION - < $KEYFILE
cryptsetup --batch-mode --verbose luksFormat --key-file $KEYFILE $STORAGE_PARTITION

# fill swap with 0s - takes ages & not sure if necessary in our case
# dd if=/dev/zero bs=1024000 of=$SWAP_PARTITION

# open partiotion (for elsewhere)
echo " - open encrypted storage partition"
cryptsetup open $STORAGE_PARTITION $STORAGE_PARTITION_LABEL --key-file $KEYFILE

#echo " - add key once again"
#cryptsetup luksAddKey $STORAGE_PARTITION $KEYFILE

# format the swap
echo " - format the swap"
#mkswap $SWAP_MAPPED_DEVICE
mkswap -L ${SWAP_PARTITION_LABEL} $SWAP_PARTITION

# format it to btrfs
mkfs.btrfs $STORAGE_MAPPED_DEVICE -L $STORAGE_PARTITION_LABEL

# exit # early for debug purposes

# mount the storage partition
mkdir -p $STORAGE_MOUNTPOINT
mount -t btrfs $STORAGE_MAPPED_DEVICE $STORAGE_MOUNTPOINT

# convert devices to UUIDs/labels, not sda/sdb before writing fstab/crypttab
echo " - get partitions as UUIDs/labels"
#SWAP_PARTITION_UUID=/dev/disk/by-label/$(blkid -s LABEL -o value $SWAP_PARTITION)
# actually use id for swap, because its label & uuid is different after every restart
#SWAP_PARTITION_BY_LABEL=/dev/disk/by-label/${SWAP_PARTITION_LABEL}
SWAP_PARTITION_BY_ID=$(./get_part_id.py $SWAP_PARTITION)
echo $SWAP_PARTITION $SWAP_PARTITION_BY_ID
STORAGE_PARTITION_BY_UUID=/dev/disk/by-uuid/$(blkid -s UUID -o value $STORAGE_PARTITION)
#STORAGE_PARTITION_BY_UUID=/dev/disk/by-uuid/$(cryptsetup luksUUID $STORAGE_PARTITION)
echo $STORAGE_PARTITION $STORAGE_PARTITION_BY_UUID

# decrypt and mount automatically on boot
echo " - write crypttab"
$DIR/write_crypttab.sh $SWAP_PARTITION_BY_ID $STORAGE_PARTITION_BY_UUID
echo " - open encrypted devices using crypttab"
cryptdisks_start $SWAP_PARTITION_LABEL
cryptdisks_start $STORAGE_PARTITION_LABEL

echo " - write fstab"
$DIR/write_fstab.sh

# start using the swap
swapon $SWAP_MAPPED_DEVICE

$DIR/create_btrfs_partitions.sh

mount -a
mount /var/lib/docker
mount /opt/cloudfleet/data

echo "complete"

exit
