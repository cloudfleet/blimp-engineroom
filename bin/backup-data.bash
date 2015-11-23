#!/bin/bash
#
# Backup /opt/cloudfleet/data

DIR=$( cd "$( dirname $0 )" && pwd )
. "${DIR}/init.bash"

backup_dir=/var/tmp
file=opt-cloudfleet-data
date=$( date "+%Y%m%d%H%M" )

file_path="${backup_dir}/${file}-${date}"
echo "Backing up "$CF_DATA" to $file_path"
cd $(dirname $CF_DATA) && tar -xvz --file "${file_path} --exclude .snapshot ./data


