#!/bin/sh
#
# This script updates the engine room.
#
# WARNING: Be very careful when changing this file!

DIR=$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )
echo "========================================"
echo " Upgrading engine room ..."
echo "========================================"

(cd $DIR && git pull)

echo "========================================"
echo " Upgraded engine room"
echo "========================================"
