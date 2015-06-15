#!/bin/bash
#
# This script upgrades all parts of the blimp. First the engine room itself,
# then the system and last the containers.
#
# WARNING: Do not change this file if you are not totally sure you know what
# you are doing as it might break the upgrade process

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )

echo "========================================"
echo " Upgrading blimp ..."
echo "========================================"

T="$(date +%s)"
$DIR/upgrade-engine-room.sh
$DIR/upgrade-system.sh
$DIR/upgrade-containers.sh
T="$(($(date +%s)-T))"

echo "========================================"
echo " Upgrade and restart took ${T} seconds."
echo "========================================"
