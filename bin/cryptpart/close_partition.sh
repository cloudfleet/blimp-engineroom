#!/bin/bash

DIR=$( cd "$( dirname $0 )" && pwd )
. $DIR/set_partition_vars.sh

# disable swap
swapoff -a

# unmount the partition
echo "unmounting the partition"
umount $STORAGE_MOUNTPOINT

# close the LUKS partition
echo "closing the LUKS partition"
cryptsetup close $STORAGE_PARTITION_LABEL

exit
