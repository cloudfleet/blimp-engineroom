# -*- coding: utf-8 -*-

import re

SWAP_LABEL = 'cf-swap'
STORAGE_LABEL = 'cf-str'

def parse_lsblk(lsblk_pairs_output):
    """Parse 'lsblk --pairs' output into dictionary."""
    disks = []
    for line in lsblk_pairs_output:
        # split on newlines after double quotes
        # to avoid: splitting NAME="cf-swap (dm-1)"
        pairs = re.split('\"\s+', line)
        d = {}
        for pair in pairs:
            key_value = re.split('="', pair)
            if len(key_value) != 2:
                continue
            key = key_value[0]
            value = key_value[1]
            if len(value) > 0 and value[-1] == '"':
                # remove trailing quote
                value = value[:-1]
            d[key] = value
        node_type = d['TYPE']
        node_size = d['SIZE']
        
        if node_type in set(['disk', 'loop']):  # or blk_list[0][0] not in set(['└', '├', '│', ' ']):
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
        if node_type in set(['crypt']):
            node_name = d['NAME']
            node_name_parts = node_name.split(' ')
            if len(node_name_parts) > 1:
                # the odd case when NAME="cf-str (dm-0)"
                partition['crypt'] = node_name_parts[0]
            else:
                # the usual case when NAME="cf-str"
                partition['crypt'] = node_name
    return disks

def parse_blk_orig(blk_file):
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

