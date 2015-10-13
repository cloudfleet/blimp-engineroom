#!/bin/bash

# wipe sda and sdb devices and label them

DIR=$( cd "$( dirname $0 )" && pwd )
. $DIR/set_partition_vars.sh

$DIR/close_partitions.sh

function wipe_drives(){
    hdd="/dev/sda /dev/sdb"
    for i in $hdd; do
	echo "d
1
d
2
d
3
n
p
1


w
" | fdisk $i; done

    mkfs.ext3 /dev/sda1 -L ${STORAGE_PARTITION_LABEL}
    mkfs.ext3 /dev/sdb1 -L ${KEY_PARTITION_LABEL}
}

#wipe_drives

# revert fstab, crypttab

if [ -f /etc/fstab.original ]
then
    # we already made a copy of the first fstab, bring it back
    mv /etc/fstab /etc/fstab.backup
    cp /etc/fstab.original /etc/fstab    
else
    # zZZ
    :
fi

mv /etc/crypttab /etc/crypttab.backup
