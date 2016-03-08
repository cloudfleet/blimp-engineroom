#!/bin/bash
# blimp-engineroom startup script meant to run on every reboot

DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "${DIR}/init.bash"

# open encrypted partitions
# (can't happen sooner due to systemd ignoring keyscript on Debian >=8.1)
. $DIR/upgrade-system.bash # First try to upgrade the OS
$DIR/cryptpart/cryptpart_startup.sh

# Copy cryptographic key
storage_key=${CF_SHARED}/crypt/storage-key
mkdir -p $(dirname $storage_key)
cp /mnt/storage-key/key $storage_key
#  TODO examine how we separate privileges
chmod a+r $storage_key

# now start the usual engineroom drill
. "$DIR/upgrade-blimp.sh"

# Copy the startup log over to permanent storage
mkdir -p ${CF_LOGS}
if [ -r ${CF_VAR}/startup.log ]; then
    echo Merging startup log to ${CF_LOGS}
    cat ${CF_VAR}/startup.log >> ${CF_LOGS}/startup.log
    rm ${CF_VAR}/startup.log
fi


exit 0
