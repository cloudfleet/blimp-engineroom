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

if [ ! -f /opt/cloudfleet/data/shared/users/users.json ]; then
  echo "{users:{}}" > /opt/cloudfleet/data/shared/users/users.json
fi

# For now always update apps file (until users can customize apps list)
cp $DIR/../templates/apps.yml /opt/cloudfleet/data/config

$DIR/create-crontab.sh

CLOUDFLEET_OTP=$(ip addr | grep -1 eth0: | tail -1 | awk '{print $2}' | sed s/://g)

mkdir -p /opt/cloudfleet/data/shared/tls
if [ ! -f /opt/cloudfleet/data/shared/tls/tls_key.pem ]; then
  $DIR/request_domain.py $CLOUDFLEET_OTP && \
  openssl req -x509 -nodes -newkey rsa:4096 \
    -keyout /opt/cloudfleet/data/shared/tls/tls_key.pem \
    -out /opt/cloudfleet/data/shared/tls/tls_crt.pem \
    -subj /C=/ST=/L=/O=CloudFleet/OU=/CN=blimp.$(cat /opt/cloudfleet/data/config/domain.txt) && \
  openssl req -new -sha256 \
    -key /opt/cloudfleet/data/shared/tls/tls_key.pem \
    -out /opt/cloudfleet/data/shared/tls/tls_req.pem \
    -subj /C=/ST=/L=/O=CloudFleet/OU=/CN=blimp.$(cat /opt/cloudfleet/data/config/domain.txt)    
fi

if [ -f /opt/cloudfleet/data/config/domain.txt ]; then
  CLOUDFLEET_DOMAIN=$(cat /opt/cloudfleet/data/config/domain.txt)
  #if [ ! -f /opt/cloudfleet/data/shared/tls/cert-requested.status ]; then
    $DIR/request_cert.py \
        $CLOUDFLEET_DOMAIN \
        $CLOUDFLEET_OTP \
        /opt/cloudfleet/data/shared/tls/tls_req.pem \
        && \
        touch /opt/cloudfleet/data/shared/tls/cert-requested.status
  #fi

  if [ ! -f /opt/cloudfleet/data/config/blimp-vars.sh ]; then
    sleep 5
    $DIR/request_secret.py \
        $CLOUDFLEET_DOMAIN \
        /opt/cloudfleet/data/shared/tls/tls_key.pem \
        /opt/cloudfleet/data/shared/tls/tls_crt.pem \
        /opt/cloudfleet/data/config/blimp-vars.sh
  fi
fi

echo "====================================="
echo "`date "+%F %T"`  Initialized config where necessary ... "
echo "====================================="
