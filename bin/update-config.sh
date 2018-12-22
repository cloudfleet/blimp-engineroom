#!/bin/bash
#
# This script updates the docker-compose and nginx configuration files based on
# installed apps and users.
DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

source $DIR/cloudfleet-vars.sh
source /opt/cloudfleet/data/config/blimp-vars.sh

export CLOUDFLEET_SPIRE_HOST
export CLOUDFLEET_BLIMP_MODEL
export CLOUDFLEET_REGISTRY
export CLOUDFLEET_DOMAIN
export CLOUDFLEET_SECRET
export CLOUDFLEET_STAGE

echo "====================================="
echo "`date "+%F %T"`  Refreshing docker-compose file ... "
echo "====================================="

cd $DIR/../templates
meta-compose \
  -d /opt/cloudfleet/data/config/apps.json \
  -o /opt/cloudfleet/data/config/cache/docker-compose.yml


echo "====================================="
echo "`date "+%F %T"`  Refreshed docker-compose file ...  "
echo "====================================="
