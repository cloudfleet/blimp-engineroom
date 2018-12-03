CLOUDFLEET_HOST=wateringhole.woolly.social:443
if lscpu | grep -i ARMv7 ; then
  CLOUDFLEET_REGISTRY=registry.marina.io
else
  CLOUDFLEET_REGISTRY=registry.hub.docker.com
fi
