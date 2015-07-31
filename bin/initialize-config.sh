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

# Set crontab
crontab - <<EOF
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
0 4 * * * /opt/cloudfleet/engineroom/bin/upgrade-blimp.sh >> /opt/cloudfleet/data/logs/blimp-upgrade.log 2>&1
EOF


mkdir -p /opt/cloudfleet/data/shared/tls
if [ ! -f /opt/cloudfleet/data/shared/tls/tls_key.pem ]; then
  CLOUDFLEET_DOMAIN=$(cat /opt/cloudfleet/init/domain.txt)
  openssl req -x509 -nodes -newkey rsa:4096 \
    -keyout /opt/cloudfleet/data/shared/tls/tls_key.pem \
    -out /opt/cloudfleet/data/shared/tls/tls_req.pem \
    -subj /C=/ST=/L=/O=CloudFleet/OU=/CN=blimp.$CLOUDFLEET_DOMAIN

    cp /opt/cloudfleet/data/shared/tls/tls_req.pem /opt/cloudfleet/data/shared/tls/tls_crt.pem
fi

if [ ! -f /opt/cloudfleet/data/shared/tls/cert-requested.status ]; then
  CLOUDFLEET_OTP=$(cat /opt/cloudfleet/init/otp.txt)
  CLOUDFLEET_DOMAIN=$(cat /opt/cloudfleet/init/domain.txt)
  $DIR/request_cert.py \
      $CLOUDFLEET_DOMAIN \
      $CLOUDFLEET_OTP \
      /opt/cloudfleet/data/shared/tls/tls_req.pem \
      && \
      touch /opt/cloudfleet/data/shared/tls/cert-requested.status
fi

if [ ! -f /opt/cloudfleet/data/config/blimp-vars.sh ]; then
  $DIR/request_secret.py \
      $CLOUDFLEET_DOMAIN \
      /opt/cloudfleet/data/shared/tls/tls_key.pem \
      /opt/cloudfleet/data/config/blimp-vars.sh
fi


echo "====================================="
echo "`date "+%F %T"`  Initialized config where necessary ... "
echo "====================================="
