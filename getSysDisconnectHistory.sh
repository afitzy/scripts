#!/bin/bash

cat /var/log/syslog | grep -E 'NetworkManager.*state change: disconnected'
