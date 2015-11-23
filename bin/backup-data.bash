#!/bin/bash
#
# Backup /opt/cloudfleet/data

DIR=$( cd "$( dirname $0 )" && pwd )
. "${DIR}/init.bash"

# as root...
if [ $(id -u) != 0 ]; then
    echo Insufficient privilege to backup $CF_DATA && exit 1
fi


backup_dir=/var/tmp
file=opt-cloudfleet-data
date=$( date "+%Y%m%d%H%M" )

file_path="${backup_dir}/${file}-${date}.tar.gz"
echo "Backing up "$CF_DATA" to $file_path"
cd $(dirname $CF_DATA) && tar -cvz --file "${file_path}" --exclude .snapshot ./data


