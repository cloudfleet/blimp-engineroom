#!/bin/bash
#
# This script is used to initialize the configuration.
# If something is already initialized, it doesn't do anything.
# (Except updating the apps.yml file)
DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "====================================="
echo "`date "+%F %T"`  Initializing config where necessary ... "
echo "====================================="

# check that USBs with correctly labeled partitions exist and if so
# prepare and encrypt key, storage, swap
# XXX potentially move out of initialize config, as it has potential fatal side effects
echo Launching cryptpart
(cd $DIR/cryptpart; . ./encrypt_device.sh)
echo Finished cryptpart

# docker-compose will be rendered in this folder
mkdir -p /opt/cloudfleet/data/config/cache
mkdir -p /opt/cloudfleet/data/shared/users
mkdir -p /opt/cloudfleet/data/logs


if [ ! -f /opt/cloudfleet/data/shared/users/users.json ]; then
  echo "{users:{}}" > /opt/cloudfleet/data/shared/users/users.json
fi

. $DIR/create-crontab.sh

echo "====================================="
echo "`date "+%F %T"`  Initialized config where necessary ... "
echo "====================================="
