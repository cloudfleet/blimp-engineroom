#!/bin/bash

# source: http://xmodulo.com/how-to-create-encrypted-disk-partition-on-linux.html

# TODO - noninteractive fdisk
# fdisk /dev/sda

# TODO:
# - make noninteractive
# - get partition name from lsblk
cryptsetup --verbose --verify-passphrase luksFormat /dev/sda1

# open partiotion (for elsewhere)
# cryptsetup luksOpen /dev/sda1 sda1

exit
