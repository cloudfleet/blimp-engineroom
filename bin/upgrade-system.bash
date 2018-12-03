#!/bin/bash
#
# This file handles upgrades to the operating system on the Blimp
#

DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "${DIR}/init.bash"

echo "====================================================================="
echo "`date "+%F %T"` Checking on upgrades for operating system ..."
echo "====================================================================="

timestamp="$CF_VAR/last-os-upgrade.timestamp"
upgraded_p=""

function upgrade_and_update {
      touch $timestamp
      export DEBIAN_FRONTEND=noninteractive
      apt-get -y update
      apt-get -y upgrade
      upgraded_p="t"
}

if [ -r $timestamp ]; then
    if [ -z $(find "$timestamp" -mtime -1) ] ; then
        upgrade_and_update
    fi
else
    upgrade_and_update
fi

if [[ -z "$upgraded_p" ]]; then
    echo Upgrading finished.
else
    echo Skipped upgrade because previous engineroom OS upgrade occurred less than an hour ago.
fi

echo "==============================================================="
echo "`date "+%F %T"` Finished operating system upgrade check"
echo "==============================================================="
