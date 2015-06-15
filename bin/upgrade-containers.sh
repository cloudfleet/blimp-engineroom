#!/bin/sh
#
# This script updates and restarts the containers and the docker-compose.yml

DIR=$( cd "$( dirname $0 )" && pwd )

echo "========================================"
echo " Upgrading containers ..."
echo "========================================"

$DIR/update-images.sh
$DIR/stop-containers.sh
$DIR/update-config-cache.sh
$DIR/start-containers.sh


echo "========================================"
echo " Upgraded containers"
echo "========================================"
