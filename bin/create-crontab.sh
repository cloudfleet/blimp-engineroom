#!/bin/bash
# Setup crontab
#
# XXX This obliterates any existing crontab entries everytime
#
#
# TODO: centralize setting values for directories (location of engineroom, logs, etc.)
crontab - <<EOF
PATH=/usr/local/sbin:/usr/local/bin:/sbin:/bin:/usr/sbin:/usr/bin
0 4 * * * sleep ${RANDOM:0:2}m; /opt/cloudfleet/engineroom/bin/upgrade-blimp.sh >> /opt/cloudfleet/data/logs/blimp-upgrade.log 2>&1
@reboot /opt/cloudfleet/engineroom/bin/startup.sh >> /opt/cloudfleet/var/startup.log 2>&1
EOF

