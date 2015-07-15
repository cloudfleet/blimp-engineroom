#!/bin/bash
#
# This script is used to initialize the configuration.
# If something is already initialized, it doesn't do anything.
# (Except updating the apps.yml file)



DIR=$( cd "$( dirname $0 )" && pwd )

echo "====================================="
echo "`date "+%F %T"`  Initializing config where necessary ... "
echo "====================================="


# docker-compose will be rendered in this folder
mkdir -p /opt/cloudfleet/data/config/cache
mkdir -p /opt/cloudfleet/data/shared/users

if [ -f /opt/cloudfleet/data/shared/users/users.json ]; then
  echo "{users:{}}" > /opt/cloudfleet/data/shared/users/users.json
fi

# For now always update apps file (until users can customize apps list)
cp $DIR/../templates/apps.yml /opt/cloudfleet/data/config

# wget -qO- https://spire.cloudfleet.io/api/v1/blimp/init \
#      --header=X_AUTH_ONE_TIME=`cat /opt/cloudfleet/one-time-key` \
# > /opt/cloudfleet/data/config/blimp-vars.sh
if [ -f /opt/cloudfleet/data/config/blimp-vars.sh ]; then
  cp /tmp/blimp-vars.sh /opt/cloudfleet/data/config/blimp-vars.sh
fi

source /opt/cloudfleet/data/config/blimp-vars.sh

mkdir -p /opt/cloudfleet/data/shared/tls
if [ ! -f /opt/cloudfleet/data/shared/tls/tls_key.pem ]; then
  openssl req -x509 -nodes -newkey rsa:4096 \
    -keyout /opt/cloudfleet/data/shared/tls/tls_key.pem \
    -out /opt/cloudfleet/data/shared/tls/tls_req.pem \
    -subj /C=/ST=/L=/O=CloudFleet/OU=/CN=blimp.$CLOUDFLEET_DOMAIN

    cp /opt/cloudfleet/data/shared/tls/tls_req.pem /opt/cloudfleet/data/shared/tls/tls_crt.pem
fi

if [ ! -f /opt/cloudfleet/data/shared/tls/cert-requested.status ]; then
  $DIR/request_cert.py \
      $CLOUDFLEET_DOMAIN \
      $CLOUDFLEET_SECRET \
      /opt/cloudfleet/data/shared/tls/tls_req.pem \
      && \
      touch /opt/cloudfleet/data/shared/tls/cert-requested.status
fi
echo "====================================="
echo "`date "+%F %T"`  Initialized config where necessary ... "
echo "====================================="
