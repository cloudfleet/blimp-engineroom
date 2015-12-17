#!/bin/bash

# cryptpart startup script meant to run on every reboot
# - would happen automatically pre-systemd (Debian <8.1)
# - now we manually have to do it and start any services that depend on these mountpoint (docker)

DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# if no cryptpart-ready devices, leave (VMs or devices with no storage/key devices)
. $DIR/set_partition_vars.sh
if [ -z "$KEY_PARTITION" ]; then
    tput setaf 1; echo "No key partition marked by label ${KEY_PARTITION_LABEL}. Quitting cryptpart_startup."; tput sgr0
    exit 1
fi
if [ -z "$STORAGE_DEVICE" ]; then
    tput setaf 1; echo "No storage device marked by partition label or LUKS partition label ${STORAGE_PARTITION_LABEL}. Quitting cryptpart_startup."; tput sgr0
    exit 1
fi

# just in case docker's autostart wasn't disabled
service docker stop

# open encrypted partitions
$DIR/open_partition.sh

service docker start

exit
