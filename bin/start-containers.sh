#!/bin/bash
#
# This script starts the blimp's docker containers based on the existing
# docker-compose.yml in /opt/cloudfleet/data/config/cache

DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

echo "=============================="
echo "`date "+%F %T"` Starting containers ... "
echo "=============================="

function run_compose(){
    docker-compose -p blimp \
      -f $DIR/../compositions/docker-compose.yml \
      -f $DIR/../compositions/apps/banner/composition.yml \
      --env-file /opt/cloudfleet/data/config/blimp.env \
      up -d
}
run_compose

# Fixes for issues with the Docker daemon hanging sometimes
# https://github.com/docker/compose/issues/1045
function all_containers_running(){
  return 0 # FIXME implement check
}

tries=1
function try_until_all_up(){
    max_tries=3
    while ! all_containers_running && [[ $tries -lt $max_tries ]]; do
      echo "retry"
      tries=$(($tries + 1))
      run_compose
    done
    echo "stopping after $tries tries"
}
try_until_all_up


# also noticed irqbalance seems to be leaking memory
# (apparently a problem since 2011 at least)
# http://www.pclinuxos.com/forum/index.php?topic=100977.0
# I restarted it, which may be related

echo "=============================="
echo "`date "+%F %T"`  Started containers. "
echo "=============================="
