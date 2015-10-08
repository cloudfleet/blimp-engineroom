#!/bin/bash

DIR=$( cd "$( dirname $0 )" && pwd )
. $DIR/set_partition_vars.sh

# disable swap
swapoff -a

# unmount the partitions
echo "unmounting the partitions"
umount $STORAGE_MOUNTPOINT
umount $KEY_MOUNTPOINT

# close the LUKS partition
echo "closing the LUKS partition"
cryptsetup close $STORAGE_PARTITION_LABEL
cryptsetup close $SWAP_PARTITION_LABEL

exit
