#!/bin/bash

DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. $DIR/set_partition_vars.sh

# data & docker - important names, used in write_fstab.sh
btrfs subvolume create ${STORAGE_MOUNTPOINT}/data
btrfs subvolume create ${STORAGE_MOUNTPOINT}/docker

btrfs subvol list $STORAGE_MOUNTPOINT

# potentially stop all running containers
docker_pids=$(docker ps -a -q)
if [[ ! -z "${docker_pids}" ]]; then 
    docker stop $docker_pids
fi

# stop docker if exists
service docker stop

# if paths exist, move their contents to a /tmp folder
rm -rf /tmp/cf-data
#rm -rf /tmp/docker-data
mkdir -p /tmp/cf-data/
#mkdir -p /tmp/docker-data/
if [ -d $CLOUDFLEET_DATA_PATH ] ; then
    mv ${CLOUDFLEET_DATA_PATH}/* /tmp/cf-data/
fi

# if [ -d $DOCKER_DATA_PATH ] ; then
#     mv ${DOCKER_DATA_PATH}/* /tmp/docker-data/
# fi

# we're not gonna try copying docker data, because there's too much
rm -rf /var/lib/docker/*
# in case it was on an external drive
umount /var/lib/docker

# create paths if they don't exist
mkdir -p $CLOUDFLEET_DATA_PATH
mkdir -p $DOCKER_DATA_PATH

# This is probably no longer necessary
mount -a

# These partitions are now marked noauto
mount $DOCKER_DATA_PATH
if [ $? -ne 0 ]; then
    echo "There was an error mounting $DOCKER_DATA_PATH. Won't delete anything."
    exit 1
fi

mount $CLOUDFLEET_DATA_PATH
if [ $? -ne 0 ]; then
    echo "There was an error mounting $CLOUDFLEET_DATA_PATH. Won't delete anything."
    exit 1
fi

# move data back
mv /tmp/cf-data/* ${CLOUDFLEET_DATA_PATH}/
#mv /tmp/docker-data/* ${DOCKER_DATA_PATH}/

# remove temporary folders
rm -rf /tmp/cf-data
#rm -rf /tmp/docker-data

# set permissions
chmod 700 ${CLOUDFLEET_DATA_PATH}
chmod 700 ${DOCKER_DATA_PATH}

# once again to be sure
mount /var/lib/docker

# write the new docker sysv/upstart/systemd options that use btrfs
$DIR/write_docker_opts.sh

# resume docker
service docker restart

exit
