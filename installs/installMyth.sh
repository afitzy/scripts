#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")

source "${scriptDir}/../utils.sh"

# Install MythTv using Mythbuntu PPA
# Installs:
# * Complete frontend and backend system with database
# * Plugins for a frontend system
# ...
# To-do: https://www.mythtv.org/wiki/Installing_MythTV_on_Ubuntu
function installMythtv () {
	sudo add-apt-repository --yes ppa:mythbuntu/0.29
	sudo apt-get update
	getPackages "mythtv"

	# Ditching mythplugins, since I never used mythweb
	# getPackages "mythplugins"

	# Database Configuration
	cp /etc/mythtv/mysql.txt "$HOME/.mythtv/"
	ln -s /etc/mythtv/config.xml "$HOME/.mythtv/"
	
	# Post install notes
	# * Make sure frontend pin match backend pin, else frontend will never connect
}


_VERBOSE=1

if [[ "$(getOsVers)" == "16.04" ]]; then
	installMythtv
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
