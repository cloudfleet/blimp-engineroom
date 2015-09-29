#!/bin/bash

if [ $# -eq 0 ]; then
    echo  "No device supplied as argument. E.g. ./format_partition.sh /dev/sda"
    exit 1
fi

#hdd="/dev/sda"
hdd=$1

# for actually not needed, but we could format multiple devices with hdd="/dev/sda /dev/sdb"
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

+2G
n
p
2


w
" | fdisk $i; done

#; mkfs.ext3 $i;done 

exit
