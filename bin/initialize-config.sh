#!/bin/bash
#
# This script is used to initialize the configuration.
# If something is already initialized, it doesn't do anything.
# (Except updating the apps.yml file)
DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "====================================="
echo "`date "+%F %T"`  Initializing config where necessary ... "
echo "====================================="

# docker-compose will be rendered in this folder
mkdir -p /opt/cloudfleet/data/config/cache
mkdir -p /opt/cloudfleet/data/shared/users
mkdir -p /opt/cloudfleet/data/logs


. $DIR/create-crontab.sh

echo "====================================="
echo "`date "+%F %T"`  Initialized config where necessary ... "
echo "====================================="
