#!/bin/bash

DIR=$( cd "$( dirname $0 )" && pwd )
. $DIR/set_partition_vars.sh

btrfs subvolume create ${STORAGE_MOUNTPOINT}/data
btrfs subvolume create ${STORAGE_MOUNTPOINT}/docker

btrfs subvol list $STORAGE_MOUNTPOINT

exit
