CLOUDFLEET_HOST=blimpyard.cloudfleet.io:443
CLOUDFLEET_MAIL_RELAY=cloudfleet.cloudfleet.io
if lscpu | grep -i ARMv7 ; then
  CLOUDFLEET_REGISTRY=registry.marina.io
else
  CLOUDFLEET_REGISTRY=registry.hub.docker.com
fi
