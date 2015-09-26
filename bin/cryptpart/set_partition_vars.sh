#!/bin/bash

# TODO - find where the usb drive is via lsblk, label or something.
STORAGE_DEVICE=/dev/sda
STORAGE_PARTITION=/dev/sda1
STORAGE_PARTITION_LABEL=sda1
STORAGE_MAPPED_DEVICE=/dev/mapper/$STORAGE_PARTITION_LABEL
STORAGE_MOUNTPOINT=/storage
