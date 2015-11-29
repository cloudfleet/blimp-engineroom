#!/bin/sh
#
# This file upgrades the operating system on the blimp

echo "========================================"
echo "`date "+%F %T"` Upgrading underlying operating system ..."
echo "========================================"

apt-get -y update
apt-get -y upgrade

echo "========================================"
echo "`date "+%F %T"` Upgraded underlying operating system"
echo "========================================"
