#!/bin/bash

DIR=$( cd "$( dirname $0 )" && pwd )
. $DIR/set_partition_vars.sh

# open partiotion
cryptsetup luksOpen $STORAGE_PARTITION $STORAGE_PARTITION_LABEL

# start using the swap
swapon $SWAP_MAPPED_DEVICE

# mount it once only
mkdir -p $STORAGE_MOUNTPOINT
mount $STORAGE_MAPPED_DEVICE $STORAGE_MOUNTPOINT

exit
