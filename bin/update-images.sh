#!/bin/bash
# This script updates the docker images used based on the current
# docker-compose.yml

DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=================================="
echo "`date "+%F %T"` Fetching new image versions ..."
echo "=================================="

docker-compose -p blimp \
  -f $DIR/../compositions/docker-compose.yml \
  -f $DIR/../compositions/apps/banner/composition.yml \
  --env-file /opt/cloudfleet/data/config/blimp.env \
  pull -q

echo "=================================="
echo "`date "+%F %T"` Fetched new image versions."
echo "=================================="
