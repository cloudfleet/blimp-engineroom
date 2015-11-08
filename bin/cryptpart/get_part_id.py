#!/usr/bin/python

"""Given a /dev/sdX-like partition, get its by-id path. Usage:

./get_part_id.py /dev/sda1

"""

import sys

# TODO: get output of:
# ls -l /dev/disk/by-id/* | grep sda1

# e.g.

output = """
lrwxrwxrwx 1 root root 10 Oct 12 16:54 /dev/disk/by-id/ata-WDC_WD2500BEVT-22ZCT0_WD-WXE908VF0470-partX -> ../../sdaX
lrwxrwxrwx 1 root root 10 Oct 12 16:54 /dev/disk/by-id/wwn-0x60015ee0000b237f-partX -> ../../sdaX
"""

def main():
    name = sys.argv[1].split('/')[2]
    for line in output.split('\n'):
        if len(line.rstrip()) > 0:
            without_date = line.split('/dev/disk/by-id/')[1]
            partid, partname = without_date.split(' -> ../../')
            if partname == name:
                print('/dev/disk/by-id/' + partid)
                break

if __name__ == "__main__":
    main()
