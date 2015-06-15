#!/bin/bash
# This script updates the docker images used based on the current
# docker-compose.yml 

echo "=================================="
echo " Fetching new image versions ..."
echo "=================================="

(cd /opt/cloudfleet/data/config/cache && docker-compose pull)

echo "=================================="
echo " Fetched new image versions."
echo "=================================="
