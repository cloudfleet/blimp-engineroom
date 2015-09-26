#!/bin/bash

DIR=$( cd "$( dirname $0 )" && pwd )
. $DIR/set_partition_vars.sh

# unmount the partition
umount $STORAGE_MOUNTPOINT

# close partiotion
cryptsetup luksClose $STORAGE_PARTITION_LABEL

exit
