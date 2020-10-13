#!/usr/bin/python
# -*- coding: utf-8 -*-
import sys
import pprint
import fileinput
from lib.blk_parser import parse_lsblk, SWAP_LABEL, STORAGE_LABEL

def check_correct(disks):
    """Check if swap and storage are available in lsblk output and encrypted"""
    #import pdb; pdb.set_trace()
    swap_encrypted = False
    storage_encrypted = False
    for disk in disks:
        if 'partitions' not in disk:
            continue
        for partition in disk['partitions']:
            try:
                if partition['crypt'] == SWAP_LABEL:
                    swap_encrypted = True
                if partition['crypt'] == STORAGE_LABEL:
                    storage_encrypted = True
            except KeyError:
                pass
    return swap_encrypted and storage_encrypted

# Return via sys.exit()
#  0 means don't either the partitions are ok, or that an exception has been thrown
#  non-zero means it is ok to run the encrypt setup routines
def main(argv):
    is_correct = False
    result = False
    try:
        if len(argv) > 1:
            print('Usage: ./check_partitions.py lsblk--pairs-output')
            is_correct = False
        elif len(argv) == 1:
            blk_filename = argv[0]
            with open(blk_filename) as blk_file:
                result = parse_lsblk(blk_file)
        else:
            # try to read the piped input
            result = parse_lsblk(fileinput.input())
        is_correct = check_correct(result)
        print('Are the correctly formatted USB keys for encryption mounted?  {}'.format(is_correct))
    except:
        print "Exception in running partition check: %s %s\n%s" % (sys.exc_type, sys.exc_value, sys.exc_traceback)
        sys.exit(0)
    sys.exit(int(not is_correct))

if __name__ == "__main__":
    main(sys.argv[1:])
