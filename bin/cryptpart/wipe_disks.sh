#!/bin/bash

# ./wipe_disks.sh <key device> <storage device>
# default: key=/dev/sdb, storage=/dev/sda
# wipe key and storage devices and label them
# depends:
#     apt-get install dosfstools

DIR=$( cd "$( dirname $0 )" && pwd )
. $DIR/set_partition_vars.sh

$DIR/close_partition.sh

# delete btrfs subvolumes
btrfs subvolume delete ${STORAGE_MOUNTPOINT}/data
btrfs subvolume delete ${STORAGE_MOUNTPOINT}/docker


if [ -z "$1" ]; then
    KEY_DEVICE=$1
else
    KEY_DEVICE=/dev/sdb
fi

if [ -z "$2" ]; then
    STORAGE_DEVICE=$2
else
    STORAGE_DEVICE=/dev/sda
fi

function wipe_drives(){
    hdd="$STORAGE_DEVICE $KEY_DEVICE"
    for i in $hdd; do
	echo "d
1
d
2
d
3
n
p
1


w
" | fdisk $i; done

    mkfs.vfat ${STORAGE_DEVICE}1 -n ${STORAGE_PARTITION_LABEL}
    mkfs.vfat ${KEY_DEVICE}1 -n ${KEY_PARTITION_LABEL}
    # mkfs.ext3 ${STORAGE_DEVICE}1 -L ${STORAGE_PARTITION_LABEL}
    # mkfs.ext3 ${KEY_DEVICE}1 -L ${KEY_PARTITION_LABEL}
}

wipe_drives

# revert fstab, crypttab

if [ -f /etc/fstab.original ]
then
    # we already made a copy of the first fstab, bring it back
    mv /etc/fstab /etc/fstab.backup
    cp /etc/fstab.original /etc/fstab    
else
    # zZZ
    :
fi

if [ -f /etc/crypttab ]; then
    mv /etc/crypttab /etc/crypttab.backup
fi

