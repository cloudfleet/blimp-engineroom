#!/bin/bash
#
# This script sets the variables identifying devices, partitions etc. used to create the encrypted storage.
# Since LUKS devices can't have labels, but only the decrypted mapped devices,
# some convoluted approaches are necessary to make this yield the correct output.

DIR=$( cd "$( dirname $0 )" && pwd )

# constants
#----------
# predefined labels
KEY_PARTITION_LABEL=cf-key
SWAP_PARTITION_LABEL=cf-swap
STORAGE_PARTITION_LABEL=cf-str

echo "labels: ${KEY_PARTITION_LABEL}, ${SWAP_PARTITION_LABEL}, ${STORAGE_PARTITION_LABEL}"

BASE_MOUNTPOINT=/mnt

# predefined data paths
#CLOUDFLEET_DATA_PATH=/opt/cloudfleet/data2
CLOUDFLEET_DATA_PATH=/opt/cloudfleet/data
#DOCKER_DATA_PATH=/opt/cloudfleet/docker2
DOCKER_DATA_PATH=/var/lib/docker

# key
#----
# - always on the same label == easy peasy
# - we keep the label pointer, as sda/sdb might change after reboot
KEY_PARTITION=/dev/disk/by-label/${KEY_PARTITION_LABEL}
# KEY_PARTITION=$(readlink -e ${KEY_PARTITION}) # render to real partition
KEY_MOUNTPOINT=${BASE_MOUNTPOINT}/storage-key
KEYFILE=$KEY_MOUNTPOINT/key
echo "key: ${KEY_PARTITION}, ${KEY_MOUNTPOINT}"

# storage & swap
#---------------
# - these ones are tricky
# - we first try t ocheck if there is a label
STORAGE_PARTITION=$(readlink -e /dev/disk/by-label/${STORAGE_PARTITION_LABEL})
# - but it can happen that there is no label because an encrypted LUKS device can't have a label
if [ -z "$STORAGE_PARTITION" ]; then
    # TODO: this shouldn't call cryptdisks_start - it should just parse /etc/crypttab
    # no storage partition label on any of the partitions, try crypt
    # - first attempt to open the partitions (otherwise we won't be able to read their labels)
    cryptdisks_start $SWAP_PARTITION_LABEL
    cryptdisks_start $STORAGE_PARTITION_LABEL
    # - cf-str disappears from /dev/disk/by-label/ after it's formatted so we parse lsblk
    STORAGE_DEVICE=/dev/$(lsblk | $DIR/get_storage_device.py)
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
