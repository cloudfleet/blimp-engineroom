#!/bin/bash

# print the CloudFleet one-time password (OTP) to stdout
#  - OTP is used for initially talking to the CloudFleet Spire service
#  - right now, the device's mac address is used

CLOUDFLEET_OTP=$(ip addr | grep -1 eth0: | tail -1 | awk '{print $2}' | sed s/://g)

echo $CLOUDFLEET_OTP

exit
