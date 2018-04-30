#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")

source "${scriptDir}/../utils.sh"

function installWine ()
{
	# Remove existing
	sudo apt-get remove --purge wine*
	sudo apt-get clean
	sudo apt-get autoremove

	wget https://repos.wine-staging.com/wine/Release.key
	sudo apt-key add Release.key
	sudo apt-add-repository 'https://dl.winehq.org/wine-builds/ubuntu/'

	# Enable 32-bit architecture
	sudo dpkg --add-architecture i386

	sudo apt-get update
	sudo apt-get install --install-recommends --yes winehq-staging

	# Use either...
	# /opt/wine-staging/bin/wine
	# /opt/wine-staging/bin/winecfg
}


_VERBOSE=1
if [[ "$(getOsVers)" == "16.04" ]]; then
	installWine
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi