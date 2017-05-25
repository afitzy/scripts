#!/bin/bash

source utils.sh

function installWine ()
{
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
	# Virtual machine
	getPackages "virtualbox" "virtualbox-ext-pack" "virtualbox-guest-*" "virtualbox-qt"

	# Wine
	installWine
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
