#!/bin/bash

DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
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

# once again, in case the crypttab doesn't have the right settings
cryptsetup luksClose /dev/mapper/$STORAGE_PARTITION_LABEL
cryptsetup luksClose /dev/mapper/$SWAP_PARTITION_LABEL

exit
