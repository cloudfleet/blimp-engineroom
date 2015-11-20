#!/bin/bash
#
# This script is used to initialize the configuration.
# If something is already initialized, it doesn't do anything.
# (Except updating the apps.yml file)



DIR=$( cd "$( dirname $0 )" && pwd )

echo "====================================="
echo "`date "+%F %T"`  Initializing config where necessary ... "
echo "====================================="

# check that USBs with correctly labeled partitions exist and if so
# prepare and encrypt key, storage, swap
(cd $DIR/cryptpart; ./encrypt_device.sh) 

# docker-compose will be rendered in this folder
mkdir -p /opt/cloudfleet/data/config/cache
mkdir -p /opt/cloudfleet/data/shared/users

if [ ! -f /opt/cloudfleet/data/shared/users/users.json ]; then
  echo "{users:{}}" > /opt/cloudfleet/data/shared/users/users.json
fi

# For now always update apps file (until users can customize apps list)
cp $DIR/../templates/apps.yml /opt/cloudfleet/data/config

$DIR/create-crontab.sh

CLOUDFLEET_OTP=$($DIR/get_otp.sh)

mkdir -p /opt/cloudfleet/data/shared/tls
cp $DIR/../templates/group16.pem /opt/cloudfleet/data/shared/tls/dhparams.pem

if [ ! -f /opt/cloudfleet/data/config/domain.txt ]; then
  $DIR/request_domain.py $CLOUDFLEET_OTP
fi


if [ -f /opt/cloudfleet/data/config/domain.txt ]; then
  CLOUDFLEET_DOMAIN=$(cat /opt/cloudfleet/data/config/domain.txt)

  if [ ! -f /opt/cloudfleet/data/shared/tls/tls_key.pem ]; then
    openssl req -x509 -nodes -newkey rsa:4096 \
      -keyout /opt/cloudfleet/data/shared/tls/tls_key.pem \
      -out /opt/cloudfleet/data/shared/tls/tls_crt.pem \
      -subj /C=/ST=/L=/O=CloudFleet/OU=/CN=blimp.$CLOUDFLEET_DOMAIN && \
    openssl req -new -sha256 \
      -key /opt/cloudfleet/data/shared/tls/tls_key.pem \
      -out /opt/cloudfleet/data/shared/tls/tls_req.pem \
      -subj /C=/ST=/L=/O=CloudFleet/OU=/CN=blimp.$CLOUDFLEET_DOMAIN
  fi

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
