#!/bin/bash

DIR="$(cd -P "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
. $DIR/set_partition_vars.sh

apt-get install -y rsync freebsd-buildutils # for fmtreee

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
rm -rf /tmp/cf-data && mkdir -p /tmp/cf-data/

if [ -d $CLOUDFLEET_DATA_PATH ] ; then
    rsync -avz ${CLOUDFLEET_DATA_PATH}/ /tmp/cf-data/
fi

# if [ -d $DOCKER_DATA_PATH ] ; then
#     mv ${DOCKER_DATA_PATH}/* /tmp/docker-data/
# fi

# we're not gonna try copying docker data, because there's too much
# And we're not gonna remove it in case we need it again

# in case it was on an external drive
umount /var/lib/docker

# create paths if they don't exist
mkdir -p $CLOUDFLEET_DATA_PATH
mkdir -p $DOCKER_DATA_PATH

# diagnostics
mtree_keywords="flags,gid,mode,nlink,size,link,uid" # don't include time
fmtree -c -k "${mtree_keywords}" -p /opt/cloudfleet/data > /opt/cloudfleet/opt-cloudfleet-data.mtree

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
#mv /tmp/docker-data/* ${DOCKER_DATA_PATH}/
sync

# Compare filesystem with original
fmtree -k "${mtree_keywords}" -p /opt/cloudfleet/data < /opt/cloudfleet/opt-cloudfleet-data.mtree
if [ $? -ne 0 ]; then
    echo Mismatch in ${CLOUDFLEET_DATA_PATH} mtree
    read -n 1 -r -p "Press the ANY key to continue..." # DEBUG
fi 

## DON'T remove temporary folders (we can fallback to known good
## boot).  They should be gone at next reboot anyways.

## set permissions
#chmod 700 ${CLOUDFLEET_DATA_PATH}
#chmod 700 ${DOCKER_DATA_PATH}

# once again to be sure
mount /var/lib/docker

# write the new docker sysv/upstart/systemd options that use btrfs
$DIR/write_docker_opts.sh

# resume docker
service docker restart

exit
