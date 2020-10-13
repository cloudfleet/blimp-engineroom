#!/bin/bash
#
# This script sets the variables identifying devices, partitions etc. used to create the encrypted storage.
# Since LUKS devices can't have labels, but only the decrypted mapped devices,
# some convoluted approaches are necessary to make this yield the correct output.

DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

## DEBUG whether to log all command invocations
# set -x

# constants
#----------
# predefined labels
KEY_PARTITION_LABEL=cf-key
STORAGE_PARTITION_LABEL=cf-str

BASE_MOUNTPOINT=/mnt

# predefined data paths
CLOUDFLEET_DATA_PATH=/opt/cloudfleet/data
DOCKER_DATA_PATH=/var/lib/docker

# key
#----
# - always on the same label == easy peasy
# - we keep the label pointer, as sda/sdb might change after reboot
KEY_PARTITION=/dev/disk/by-label/${KEY_PARTITION_LABEL}
KEY_MOUNTPOINT=${BASE_MOUNTPOINT}/storage-key
KEYFILE=$KEY_MOUNTPOINT/key

# storage & swap
#---------------
# - these ones are tricky
# - we first try to check if there is a label
STORAGE_PARTITION=$(readlink -e /dev/disk/by-label/${STORAGE_PARTITION_LABEL})
# - but it can happen that there is no label because an encrypted LUKS device can't have a label
if [ -z "$STORAGE_PARTITION" ]; then
    # no storage partition label on any of the partitions, try crypt partitions
    # - we parse /etc/crypttab to get the partitions
    STORAGE_PARTITION=$($DIR/get_crypttab_device.py $STORAGE_PARTITION_LABEL)
    SWAP_PARTITION=$($DIR/get_crypttab_device.py $SWAP_PARTITION_LABEL)
    # if there is no crypttab or that label, get_crypttab_device.py will return 1 and leave var unset
    if [ ! -z "$STORAGE_PARTITION" ]; then
	# there is a labeled partition, so we extract device name from it (assuming single digit)
	# TODO: a more robust method will be needed to determine the device after we switch to UUIDs
	STORAGE_DEVICE=${STORAGE_PARTITION:0:(-1)}
    fi
    # old approach of also mounting crypttab
    # # - first attempt to open the partitions (otherwise we won't be able to read their labels)
    # cryptdisks_start $SWAP_PARTITION_LABEL
    # cryptdisks_start $STORAGE_PARTITION_LABEL
    # # - cf-str disappears from /dev/disk/by-label/ after it's formatted so we parse lsblk
    # STORAGE_DEVICE=/dev/$(lsblk | $DIR/get_storage_device.py)
else
    # there is a labeled partition, so we extract device name from it (assuming single digit)
    STORAGE_DEVICE=${STORAGE_PARTITION:0:(-1)}
fi

if [ -z "$STORAGE_DEVICE" ]; then
    # still no storage device
    echo "there is no ${STORAGE_PARTITION_LABEL} label - on crypt or on actual partition"
else
    # determine the partitions (that will be or already are created)
    if [ -z "$SWAP_PARTITION" ]; then
	SWAP_PARTITION="${STORAGE_DEVICE}1"
    fi
    if [ -z "$STORAGE_PARTITION" ]; then
	STORAGE_PARTITION="${STORAGE_DEVICE}2"
    fi
fi

SWAP_MAPPED_DEVICE=/dev/mapper/$SWAP_PARTITION_LABEL
STORAGE_MAPPED_DEVICE=/dev/mapper/$STORAGE_PARTITION_LABEL

STORAGE_MOUNTPOINT=${BASE_MOUNTPOINT}/storage
