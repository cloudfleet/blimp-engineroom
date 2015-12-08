#!/bin/bash

# lsblk-blimpie-20151208a currently chokes the scrupt
for file in lsblk-blimpie-20151208a lsblk-blimpie-20151208b; do 
    cat $file | ../bin/cryptpart/check_partitions.py
done


