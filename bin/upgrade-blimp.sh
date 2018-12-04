#!/bin/bash
#
# This script upgrades all parts of the blimp. First the engine room itself,
# then the system and last the containers.
#
# WARNING: Do not change this file if you are not totally sure you know what
# you are doing as it might break the upgrade process

DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. "${DIR}/init.bash"

echo "========================================"
echo "`date "+%F %T"` Upgrading blimp ..."
echo "========================================"

T="$(date +%s)"
. $DIR/upgrade-system.bash
. $DIR/upgrade-engine-room.sh
. $DIR/initialize-config.sh
. $DIR/update-config.sh
. $DIR/upgrade-containers.sh
T="$(($(date +%s)-T))"

echo "========================================"
echo "`date "+%F %T"` Upgrade and restart took ${T} seconds."
echo "========================================"
