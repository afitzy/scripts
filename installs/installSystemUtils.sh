#!/bin/bash

source ../utils.sh

_VERBOSE=1

if [[ "$(getOsVers)" == "16.04" ]]; then
	# Disks
	getPackages "gnome-disk-utility"

	# Facilitates backing up package lists
	getPackages "aptik"
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
