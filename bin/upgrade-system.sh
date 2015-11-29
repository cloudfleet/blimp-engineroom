#!/bin/sh
#
# This file upgrades the operating system on the blimp

echo "========================================"
echo "`date "+%F %T"` Upgrading underlying operating system ..."
echo "========================================"

apt-get update
apt-get upgrade

echo "========================================"
echo "`date "+%F %T"` Upgraded underlying operating system"
echo "========================================"
