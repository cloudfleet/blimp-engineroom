#!/bin/bash

# cryptpart startup script meant to run on every reboot
# - would happen automatically pre-systemd (Debian <8.1)
# - now we manually have to do it and start any services that depend on these mountpoint (docker)

DIR=$( cd "$( dirname $0 )" && pwd )

# if nothing in cryptpart leave (VMs or devices with no storage/key devices)

# just in case its autostart wasn't disabled
service docker stop

# open encrypted partitions
$DIR/open_partition.sh

service docker start

# now start the usual engineroom drill
# TODO: blimp-upgrade.sh with log

exit
