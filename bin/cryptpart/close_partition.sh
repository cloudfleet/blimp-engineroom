#!/bin/bash

DIR=$( cd "$( dirname $0 )" && pwd )
. $DIR/set_partition_vars.sh

# first unmount and delete any btrfs subvolumes
# - stop docker if it's using /var/lib/docker
service docker stop
# - unmount btrfs subvolumes
umount ${CLOUDFLEET_DATA_PATH}
umount ${DOCKER_DATA_PATH}

# then close the bare partitions...

# disable swap
swapoff -a

# unmount the partitions
echo "unmounting the partitions"
umount $STORAGE_MOUNTPOINT
umount $KEY_MOUNTPOINT

# close the LUKS partition
echo "closing the LUKS partition"
#cryptsetup close $STORAGE_PARTITION_LABEL
#cryptsetup close $SWAP_PARTITION_LABEL
cryptdisks_stop $STORAGE_PARTITION_LABEL
cryptdisks_stop $SWAP_PARTITION_LABEL

exit
