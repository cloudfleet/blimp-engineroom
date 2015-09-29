#!/bin/bash

DIR=$( cd "$( dirname $0 )" && pwd )
. $DIR/set_partition_vars.sh

echo "# <target name> <source device> <key file> <options>
${STORAGE_PARTITION_LABEL} /dev/disk/by-uuid/$(cryptsetup luksUUID $STORAGE_PARTITION) ${KEYFILE} luks

" > /etc/crypttab
