#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")

source "${scriptDir}/../utils.sh"

_VERBOSE=1

if [[ "$(getOsVers)" == "16.04" ]]; then
	# Disks
	getPackages "gnome-disk-utility"

	# Startup disk creator
	sudo apt-get install usb-creator-kde

	# Facilitates backing up package lists
	sudo add-apt-repository -y ppa:teejee2008/ppa
	sudo apt-get update
	getPackages "aptik"
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
