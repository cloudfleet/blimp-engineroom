#!/bin/bash
#
# This script starts the blimp's docker containers based on the existing
# docker-compose.yml in /opt/cloudfleet/data/config/cache


echo "=============================="
echo "`date "+%F %T"` Starting containers ... "
echo "=============================="

# parameters to give Docker a better chance of not hanging up
export COMPOSE_HTTP_TIMEOUT=120
export DOCKER_CLIENT_TIMEOUT=120 # for older compose versions
# more go processes suggested in
# https://github.com/docker/docker/issues/9656
export GOMAXPROCS=4

function run_compose(){
    (cd /opt/cloudfleet/data/config/cache && docker-compose -p blimp up -d)
}
run_compose

# Fixes for issues with the Docker daemon hanging sometimes
# https://github.com/docker/compose/issues/1045
function all_containers_running(){
    # TODO: make this check more robust in the future so that we don't have
    # to hardcode the expected number of containers
    expected_containers=10
    active_containers=$(( $(docker ps | wc -l) - 1 ))
    if [[ $active_containers -lt $expected_containers ]]; then	
	return 1 # raise error, as not enough containers running
    else
	return 0 # expected numbers of containers running, all ok
    fi
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
