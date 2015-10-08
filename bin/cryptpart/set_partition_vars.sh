#!/bin/bash

# labels
KEY_PARTITION_LABEL=cf-key
SWAP_PARTITION_LABEL=cf-swap
STORAGE_PARTITION_LABEL=cf-str

echo "labels: ${KEY_PARTITION_LABEL}, ${SWAP_PARTITION_LABEL}, ${STORAGE_PARTITION_LABEL}"

BASE_MOUNTPOINT=/mnt

# key
KEY_PARTITION=/dev/disk/by-label/${KEY_PARTITION_LABEL}
KEY_PARTITION=$(readlink -e ${KEY_PARTITION}) # render to real partition
KEY_MOUNTPOINT=${BASE_MOUNTPOINT}/storage-key
KEYFILE=$KEY_MOUNTPOINT/key
echo "key: ${KEY_PARTITION}, ${KEY_MOUNTPOINT}"

# storage & swap
STORAGE_PARTITION=$(readlink -e /dev/disk/by-label/${STORAGE_PARTITION_LABEL})
if [ -z "$STORAGE_PARTITION" ]; then
    # no storage partition label on any of the partitions, try crypt
    # - first attempt to open the partitions (otherwise we won't be able to read their labels)
    cryptdisks_start $SWAP_PARTITION_LABEL
    cryptdisks_start $STORAGE_PARTITION_LABEL
    # - cf-str disappears from /dev/disk/by-label/ after it's formatted so we parse lsblk
    STORAGE_DEVICE=$(lsblk | ./get_storage_device.py)
else
    # there is a labeled partition, so we extract device name from it (assuming single digit)
    STORAGE_DEVICE=${STORAGE_PARTITION:0:(-1)}
fi

if [ -z "$STORAGE_DEVICE" ]; then
    # still no storage device
    echo "there is no ${STORAGE_OARTITION} label - on crypt or on actual partition"
else
    # determine the partitions (that will be or already are created)
    SWAP_PARTITION="${STORAGE_DEVICE}1"
    STORAGE_PARTITION="${STORAGE_DEVICE}2"
fi

SWAP_MAPPED_DEVICE=/dev/mapper/$SWAP_PARTITION_LABEL
STORAGE_MAPPED_DEVICE=/dev/mapper/$STORAGE_PARTITION_LABEL

STORAGE_MOUNTPOINT=${BASE_MOUNTPOINT}/storage
echo "storage: ${STORAGE_DEVICE}, ${STORAGE_PARTITION}, ${STORAGE_MAPPED_DEVICE}, ${STORAGE_MOUNTPOINT}"
echo "swap: ${SWAP_PARTITION}, ${SWAP_MAPPED_DEVICE}"
