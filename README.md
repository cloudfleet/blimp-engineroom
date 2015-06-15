Blimp Engineroom
================

The Blimp Engineroom manages and updates all the services on a blimp. It runs on bare metal.

Quick Start
-----------

Install all the Debian package requirements:

    sudo apt-get install -y docker.io python-docker cgroupfs-mount python-pip

Then just a Python package or two:

    sudo pip install meta-compose

TODO
----

- Figure out what and how to write to blimp-vars.sh
- Move the installation into a single script or update ansible scripts in blimp
