#!/bin/bash

DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. $DIR/set_partition_vars.sh

# open partiotion
#echo "cryptsetup open $STORAGE_PARTITION $STORAGE_PARTITION_LABEL --key-file $KEYFILE"
#cryptsetup open $STORAGE_PARTITION $STORAGE_PARTITION_LABEL --key-file $KEYFILE
cryptdisks_start $STORAGE_PARTITION_LABEL
cryptdisks_start $SWAP_PARTITION_LABEL

# start using the swap
swapon $SWAP_MAPPED_DEVICE

# mount it once only
mkdir -p $STORAGE_MOUNTPOINT
mount $STORAGE_MAPPED_DEVICE $STORAGE_MOUNTPOINT

mount -a
mount /var/lib/docker
mount /opt/cloudfleet/data

exit
