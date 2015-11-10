#!/bin/bash

# expected usage:
# ./write_crypttab.sh $SWAP_PARTITION_BY_ID $STORAGE_PARTITION_BY_UUID

DIR=$( cd "$( dirname $0 )" && pwd )
. $DIR/set_partition_vars.sh

if [ "$#" -eq 2 ]; then
    echo "getting partitions from arguments"
    SWAP_PARTITION=$1
    STORAGE_PARTITION=$2

    echo "# <target name> <source device> <key file> <options>
${SWAP_PARTITION_LABEL} ${SWAP_PARTITION} /dev/urandom swap,cipher=aes-cbc-essiv:sha256,size=256
${STORAGE_PARTITION_LABEL} ${STORAGE_PARTITION} ${KEY_PARTITION} luks,keyscript=/opt/cloudfleet/engineroom/bin/cryptpart/keyscript.sh
" > /etc/crypttab
else
    # this scenario is not need, except for testing
    echo "# <target name> <source device> <key file> <options>
${SWAP_PARTITION_LABEL} ${SWAP_PARTITION} /dev/urandom swap,cipher=aes-cbc-essiv:sha256,size=256
${STORAGE_PARTITION_LABEL} /dev/disk/by-uuid/$(cryptsetup luksUUID $STORAGE_PARTITION) ${KEYFILE} luks
" > /etc/crypttab
fi
