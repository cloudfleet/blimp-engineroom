#!/bin/bash

# print the CloudFleet one-time password (OTP) to stdout
#  - OTP is used for initially talking to the CloudFleet Spire service
#  - right now, the device's mac address is used

if [ -f /etc/cloudfleet/otp.txt ]; then
  CLOUDFLEET_OTP=$(cat /etc/cloudfleet/otp.txt)
else
  CLOUDFLEET_OTP=$(ip addr | grep -1 eth0: | tail -1 | awk '{print $2}' | sed s/://g)
fi

echo $CLOUDFLEET_OTP

exit
