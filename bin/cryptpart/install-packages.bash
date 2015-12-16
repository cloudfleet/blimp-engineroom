#!/bin/bash

packages="rsync freebsd-buildutils"
packages="${packages} cryptsetup"
packages="${packages} btrfs-tools"
packages="${packages} dosfstools"

apt-get -y install $packages
