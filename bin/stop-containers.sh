#!/bin/bash
#
# This script stops and removes the blimp's docker containers based on the existing
# docker-compose.yml in /opt/cloudfleet/data/config/cache
#
# It also removes all untagged docker images to avoid filling up the SD card

# parameters to give Docker a better chance of not hanging up
export COMPOSE_HTTP_TIMEOUT=120
export DOCKER_CLIENT_TIMEOUT=120 # for older compose versions
# more go processes suggested in
# https://github.com/docker/docker/issues/9656
export GOMAXPROCS=4
# - provisionally only set these params for now
# (if necessary add retries like in start-containers.sh)

echo "=================================="
echo "`date "+%F %T"`  Stopping containers ... "
echo "=================================="

(cd /opt/cloudfleet/data/config/cache && \
 docker-compose -p blimp stop \
)

echo "=================================="
echo "`date "+%F %T"`  Stopped containers. "
echo "=================================="

echo "=================================="
echo "`date "+%F %T"`  Deleting containers. "
echo "=================================="


(cd /opt/cloudfleet/data/config/cache && \
 docker-compose -p blimp rm -f \
)

echo "=================================="
echo "`date "+%F %T"`  Deleted containers. "
echo "=================================="

echo "=================================="
echo "`date "+%F %T"`  Removing obsolete images ... "
echo "=================================="


IMAGES_TO_DELETE=$(docker images | grep "^<none>" | awk '{print $3}')
if [ -n "$IMAGES_TO_DELETE" ]; then
  docker rmi -f $IMAGES_TO_DELETE
fi

echo "=================================="
echo "`date "+%F %T"`  Removed obsolete images. "
echo "=================================="
