#!/bin/bash

# TODO - find where the usb drive is via lsblk, label or something.
STORAGE_DEVICE=/dev/sda
STORAGE_PARTITION=/dev/sda2
STORAGE_PARTITION_LABEL=cloudfleet-storage
STORAGE_MAPPED_DEVICE=/dev/mapper/$STORAGE_PARTITION_LABEL
STORAGE_MOUNTPOINT=/storage
KEYFILE=/root/key
