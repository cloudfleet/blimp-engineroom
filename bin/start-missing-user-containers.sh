#!/bin/bash

DIR=$( cd "$( dirname $0 )" && pwd )

$DIR/update-config.sh

(cd /opt/cloudfleet/data/config/cache && \
 docker-compose -p blimp stop pagekite && \
 docker-compose -p blimp stop nginx && \
 docker-compose -p blimp rm -f && \
 docker-compose -p blimp up --no-recreate -d \
)
