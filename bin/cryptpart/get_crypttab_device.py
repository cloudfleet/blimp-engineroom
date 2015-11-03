#!/usr/bin/python

"""get the device where the encrypted partition is set to be in crypttab

Usage:

python get_crypttab_device.py <device_label>

"""

import sys

from lib.crypttab_parser import parse


def main():
    devices = parse()
    device_label = sys.argv[1]
    #print(devices)
    for device in devices:
        if device['label'] == device_label:
            print(device['device'])
            sys.exit(0)
    sys.exit(1)


if __name__ == "__main__":
    main()
