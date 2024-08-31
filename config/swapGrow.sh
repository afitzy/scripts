#!/bin/bash

# Ref: https://forum.endeavouros.com/t/swapfile-resize-on-btrfs/16953/40
# Reminder: change "count" to desired new size in MB
sudo swapoff /swap/swapfile
sudo truncate -s 0 /swap/swapfile
sudo dd if=/dev/zero of=/swap/swapfile bs=1M count=8092 status=progress
sudo mkswap /swap/swapfile
sudo swapon /swap/swapfile
