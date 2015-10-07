#!/usr/bin/python
# -*- coding: utf-8 -*-
import sys
import pprint
import fileinput
from lib.blk_parser import parse_blk, SWAP_LABEL, STORAGE_LABEL

def check_correct(disks):
    """check if swap and storage there and encrypted"""
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

def main(argv):
    if len(argv) > 1:
        print('Usage: ./parse.py blk_filename')
        return
    elif len(argv) == 1:
        blk_filename = argv[0]
        with open(blk_filename) as blk_file:
            result = parse_blk(blk_file)
    else:
        # try to read the piped input
        result = parse_blk(fileinput.input())
    pprint.PrettyPrinter(indent=4).pprint(result)
    is_correct = check_correct(result)
    print('is_correct: {}'.format(is_correct))
    sys.exit(int(not is_correct)) # appropriate exit code

if __name__ == "__main__":
    main(sys.argv[1:])
