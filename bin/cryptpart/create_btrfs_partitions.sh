#!/bin/bash

DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. $DIR/set_partition_vars.sh

# data & docker - important names, used in write_fstab.sh
btrfs subvolume create ${STORAGE_MOUNTPOINT}/data
btrfs subvolume create ${STORAGE_MOUNTPOINT}/docker

# potentially stop all running containers
docker_pids=$(docker ps -a -q)
if [[ ! -z "${docker_pids}" ]]; then
    docker stop $docker_pids
fi

# stop docker if exists
service docker stop

# if paths exist, move their contents to a /tmp folder
rm -rf /tmp/cf-data && mkdir -p /tmp/cf-data/

if [ -d $CLOUDFLEET_DATA_PATH ] ; then
    rsync -avz ${CLOUDFLEET_DATA_PATH}/ /tmp/cf-data/
fi


# in case it was on an external drive
umount /var/lib/docker

# create paths if they don't exist
mkdir -p $CLOUDFLEET_DATA_PATH
mkdir -p $DOCKER_DATA_PATH


# These partitions are now marked noauto
sync
mount $DOCKER_DATA_PATH
if [ $? -ne 0 ]; then
    echo "There was an error mounting $DOCKER_DATA_PATH. Won't delete anything."
    exit 1
fi
sync
mount $CLOUDFLEET_DATA_PATH
if [ $? -ne 0 ]; then
    echo "There was an error mounting $CLOUDFLEET_DATA_PATH. Won't delete anything."
    exit 1
fi
sync

# move data back
rsync -avz /tmp/cf-data/ ${CLOUDFLEET_DATA_PATH}/
sync


# once again to be sure
mount /var/lib/docker

# write the new docker sysv/upstart/systemd options that use btrfs
$DIR/write_docker_opts.sh

# resume docker
service docker restart

exit
