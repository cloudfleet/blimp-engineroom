
if [ ! -f /etc/default/docker.backup ]; then
    cp /etc/default/docker /etc/default/docker.backup
fi

echo '# Docker Upstart and SysVinit configuration file

# Customize location of Docker binary (especially for development testing).
#DOCKER="/usr/local/bin/docker"

# Use DOCKER_OPTS to modify the daemon startup options.
#DOCKER_OPTS="--dns 8.8.8.8 --dns 8.8.4.4"
#DOCKER_OPTS="--storage-driver=overlay -D"
DOCKER_OPTS="--storage-driver=btrfs -D"

# If you need Docker to use an HTTP proxy, it can also be specified here.
#export http_proxy="http://127.0.0.1:3128/"

# This is also a handy place to tweak where hte Docker temporary files go.
#export TMPDIR="/mnt/bigdrive/docker-tmp"' >> /etc/default/docker

