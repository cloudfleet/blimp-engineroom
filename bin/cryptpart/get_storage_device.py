#!/usr/bin/python

"""get the device where the encrypted storage partition is"""

import fileinput
import sys

from lib.blk_parser import parse_blk, SWAP_LABEL, STORAGE_LABEL

def main():
    disks = parse_blk(fileinput.input())
    for disk in disks:
        if 'partitions' not in disk:
            continue
        for partition in disk['partitions']:
            try:
                if partition['crypt'] == STORAGE_LABEL:
                    print(disk['name'])
                    sys.exit(0)
            except KeyError:
                pass
    sys.exit(1)

if __name__ == "__main__":
    main()
