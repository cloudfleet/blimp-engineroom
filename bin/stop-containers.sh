#!/bin/bash
#
# This script stops and removes the blimp's docker containers based on the existing
# docker-compose.yml in /opt/cloudfleet/data/config/cache
#
# It also removes all untagged docker images to avoid filling up the SD card



echo "=================================="
echo "  Stopping containers ... "
echo "=================================="

(cd /opt/cloudfleet/data/config/cache && \
 docker-compose -p blimp stop && \
 docker-compose -p blimp rm -f \
)

echo "=================================="
echo "  Stopped and deleted containers. "
echo "=================================="

echo "=================================="
echo "  Removing obsolete images ... "
echo "=================================="


IMAGES_TO_DELETE=$(docker images | grep "^<none>" | awk '{print $3}')
if [ -n "$IMAGES_TO_DELETE" ]; then
  docker rmi -f $IMAGES_TO_DELETE
fi

echo "=================================="
echo "  Removed obsolete images. "
echo "=================================="
