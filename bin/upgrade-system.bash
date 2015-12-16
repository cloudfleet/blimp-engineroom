#!/bin/sh
#
# This file upgrades the operating system on the blimp

DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "${DIR}/init.bash"

echo "========================================"
echo "`date "+%F %T"` Upgrading underlying operating system ..."
echo "========================================"

timestamp="$CF_VAR/last-os-upgrade.timestamp"

function upgrade_and_update {
      touch $timestamp
      apt-get -y update
      apt-get -y upgrade
}
    
if [ -r $timestamp ]; then
    if [ -z $(find "$timestamp" -mtime -60m) ] ; then
        upgrade_and_update
    fi
else
    upgrade_and_update
fi

echo "========================================"
echo "`date "+%F %T"` Upgraded underlying operating system"
echo "========================================"
