#!/bin/bash
#
# This script updates the engine room.
#
# WARNING: Be very careful when changing this file!

DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
echo "========================================"
echo "`date "+%F %T"` Upgrading engine room ..."
echo "========================================"

(cd $DIR && git pull -f)

echo "========================================"
echo "`date "+%F %T"` Upgraded engine room"
echo "========================================"
