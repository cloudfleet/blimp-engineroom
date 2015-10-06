#!/usr/bin/python
# -*- coding: utf-8 -*-
import sys
import re
import pprint
import fileinput


# for line in fileinput.input():
#     pass

def parse_blk(blk_file):
    disks = []
    for line in blk_file:
        if line.startswith('NAME'): # skip first line
            continue
        blk_list = re.split('\s+', line)
        node_type = blk_list[5]
        node_size = blk_list[3]
        if node_type in set(['disk', 'loop']): # or blk_list[0][0] not in set(['└', '├', '│', ' ']):
            # new disk
            disk = {'name': blk_list[0], 'type': node_type, 'size': node_size}
            if node_type == 'disk':
                disk['partitions'] = []
            disks.append(disk)
            # get size info if relevant
            continue
        if node_type in set(['part', 'dm']):
            # new partition (or whatever dm is)
            node_name = blk_list[0].split('\x80')[1]
            partition = {'name': node_name, 'type': node_type, 'size': node_size}
            disk['partitions'].append(partition)
            continue
        if len(blk_list) > 8: # if node_type == 'crypt':
            # crypt belonging to a partition
            node_name = blk_list[1].split('\x80')[1]
            partition['crypt'] = node_name

    return disks

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
                if partition['crypt'] == 'cloudfleet-swap':
                    swap_encrypted = True
                if partition['crypt'] == 'cloudfleet-storage':
                    storage_encrypted = True
            except KeyError:
                pass
    return swap_encrypted and storage_encrypted

def main(argv):
    if len(argv) > 1:
        print 'Usage: ./parse.py blk_filename'
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
    sys.exit(int(not is_correct)) # appropriate exit code

if __name__ == "__main__":
    main(sys.argv[1:])
