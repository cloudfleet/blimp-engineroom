#!/bin/bash
#
# This script starts the blimp's docker containers based on the existing
# docker-compose.yml in /opt/cloudfleet/data/config/cache


echo "=============================="
echo "  Starting containers ... "
echo "=============================="

(cd /opt/cloudfleet/data/config/cache && docker-compose up -d)

echo "=============================="
echo "  Started containers. "
echo "=============================="
