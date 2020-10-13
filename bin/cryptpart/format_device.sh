#!/bin/bash

if [ $# -eq 0 ]; then
    echo  "No device supplied as argument. E.g. ./format_partition.sh /dev/sda"
    exit 1
fi

#hdd="/dev/sda"
hdd=$1

# format using fdisk
# (for loop not needed, but we could format multiple devices with hdd="/dev/sda /dev/sdb")
# - delete up to 3 existing partitions
# - create a 2 GB primary partition (swap)
# - fill up the remaining empty space with the second partition (storage)
for i in $hdd;do
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

exit
