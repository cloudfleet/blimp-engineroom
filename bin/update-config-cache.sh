#!/bin/bash
#
# This script updates the docker-compose and nginx configuration files based on
# installed apps and users.

DIR=$( cd "$( dirname $0 )" && pwd )
source $DIR/cloudfleet-vars.sh
source /opt/cloudfleet/data/config/blimp-vars.sh

echo "====================================="
echo "  Refreshing docker-compose file ... "
echo "====================================="

mkdir -p /opt/cloudfleet/data/config/cache/nginx/
cd $DIR/../templates
meta-compose \
  -d /opt/cloudfleet/data/config/apps.yml \
  -d /opt/cloudfleet/data/shared/users/users.json \
  -o /opt/cloudfleet/data/config/cache/docker-compose.yml

echo "====================================="
echo "  Refreshed docker-compose file ...  "
echo "====================================="
