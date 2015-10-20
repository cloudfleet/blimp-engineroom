#!/bin/bash

DIR=$( cd "$( dirname $0 )" && pwd )
. $DIR/set_partition_vars.sh

# data & docker - important names, used in write_fstab.sh
btrfs subvolume create ${STORAGE_MOUNTPOINT}/data
btrfs subvolume create ${STORAGE_MOUNTPOINT}/docker

btrfs subvol list $STORAGE_MOUNTPOINT

# stop all running containers
docker stop $(docker ps -a -q)

# stop docker if exists
service docker stop


# if paths exist, move their contents to a /tmp folder
if [ -d $CLOUDFLEET_DATA_PATH ] ; then
    mkdir -p /tmp/cf-data
fi

if [ -d $DOCKER_DATA_PATH ] ; then
    mkdir -p /tmp/docker-data
fi

# create paths if they don't exist
mkdir -p $CLOUDFLEET_DATA_PATH
mkdir -p $DOCKER_DATA_PATH


mount -a

if [ $? -ne 0 ]; then
    echo "There was an error mounting something. Won't delete anything."
    exit 1
fi

# remove temporary folders
rm -rf /tmp/cf-data
rm -rf /tmp/docker-data


# resume docker
service docker restart

exit
