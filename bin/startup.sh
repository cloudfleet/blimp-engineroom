#!/bin/bash


# engineroom startup script meant to run on every reboot

DIR=$( cd "$( dirname $0 )" && pwd )
. "${DIR}/init.bash"

# open encrypted partitions
# (can't happen sooner due to systemd ignoring keyscript on Debian >=8.1)
. $DIR/cryptpart/cryptpart_startup.sh


# now start the usual engineroom drill
#mkdir -p /opt/cloudfleet/data/logs/
. /opt/cloudfleet/engineroom/bin/upgrade-blimp.sh

exit
