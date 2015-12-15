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
            # Why wouldn't we continue with the loop?
            # What if there is more than one crypt partition?
    return disks

def parse_blk2(lsblk_pairs_output):
    """Parse lsblk output with --pairs option into dictionary"""
    disks = []
    for line in lsblk_pairs_output:
        pairs = re.split('\s+', line)
        d = {}
        for pair in pairs:
            key_value = re.split('="', pair)
            key = key_value[0]
            value = key_value[:-1]
            d[key] = value
        node_type = d['TYPE']
        node_size = d['SIZE']
        if node_type in set(['disk', 'loop']): # or blk_list[0][0] not in set(['└', '├', '│', ' ']):
            disk = {'name': d['NAME'], 'type': node_type, 'size': node_size, 'mountpoint': d['MOUNTPOINT']}
            if node_type == 'disk':
                disk['partitions'] = []
            disks.append(disk)
            # get size info if relevant
            continue
        if node_type in set(['part', 'dm']):
            # new partition (or whatever dm is)
            node_name = d['NAME']
            partition = {'name': node_name, 'type': node_type, 'size': node_size, 'mountpoint': d['MOUNTPOINT']}
            disk['partitions'].append(partition)
            continue
        # XXX Diverges from original code
        if node_type in set(['crypt']):
            node_name = d['NAME']
            partition = {'name': node_name, 'type': node_type, 'size': node_size, 'mountpoint': d['MOUNTPOINT']}
            disk['partitions'].append(partition)
            continue
    return disks
