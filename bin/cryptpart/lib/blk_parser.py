# -*- coding: utf-8 -*-

import re

SWAP_LABEL = 'cf-swap'
STORAGE_LABEL = 'cf-str'

def parse_blk(blk_file):
    """parse lsblk output into a dictionary"""
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

