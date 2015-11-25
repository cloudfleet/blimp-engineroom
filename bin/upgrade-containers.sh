#!/bin/sh
#
# This script updates and restarts the containers and the docker-compose.yml

DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "========================================"
echo "`date "+%F %T"` Upgrading containers ..."
echo "========================================"

$DIR/update-images.sh
$DIR/stop-containers.sh
$DIR/update-config.sh
$DIR/start-containers.sh


echo "========================================"
echo "`date "+%F %T"` Upgraded containers"
echo "========================================"
