#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")

source "${scriptDir}/../utils.sh"

_VERBOSE=1


# Facilitates backing up package lists
function getAptik () {
	if [[ "$(getOsVers)" == "16.04" || "$(getOsVers)" == "18.04" || "$(getOsVers)" == "20.04" ]]; then
		local friendlyName="aptik"

		echo "${friendlyName}: installing"
		sudo add-apt-repository --yes ppa:teejee2008/ppa
		sudo apt-get update
		sudo apt-get install --yes aptik
	else
		echo "Unrecognized OS version. Not installed pre-requisites."
	fi
}


if [[ "$(getOsVers)" == "16.04" || "$(getOsVers)" == "18.04" || "$(getOsVers)" == "20.04" || "$(getOsVers)" == "22.04" || "$(getOsVers)" == "24.04" ]]; then
	# Disks
	sudo apt-get install --yes gnome-disk-utility

	# show where your diskspace is being used
	sudo apt-get install --yes filelight

	# Startup disk creator
	sudo apt-get install --yes usb-creator-kde
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi

getAptik
