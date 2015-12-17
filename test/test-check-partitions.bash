#!/bin/bash

# Old 'lsblk' input examples
#inputs="lsblk-blimpie-20151208a lsblk-blimpie-20151208b"
# New 'lsblk --pairs' input examples
inputs="lsblk-blimpie-pairs-20151215a"

for file in $inputs; do 
    cat $file | ../bin/cryptpart/check_partitions.py
done


