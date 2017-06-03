#!/bin/bash

source utils.sh

# Install MythTv using Mythbuntu PPA
# Installs:
# 1) Complete frontend and backend system with database
# 2) Plugins for a frontend system
function installMythtv () {
	sudo add-apt-repository --yes ppa:mythbuntu/0.28
	sudo apt-get update
	getPackages "mythtv" "mythplugins"
}


_VERBOSE=1

if [[ "$(getOsVers)" == "16.04" ]]; then
	installMythtv
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
