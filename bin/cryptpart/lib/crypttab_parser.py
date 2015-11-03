#!/usr/bin/python

def parse():
    with open('/etc/crypttab', 'r') as crypttab_file:
        devices = []
        for line in crypttab_file:
            line = line.rstrip()
            if len(line) == 0:
                continue
            if line[0] == '#':
                continue
            parts = line.split()
            label, device, mountpoint, options = parts
            device = {
                'label': label,
                'device': device,
                'mountpoint': mountpoint,
                'options': options
            }
            devices.append(device)
        return devices
