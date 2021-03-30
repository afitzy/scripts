#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")

source "${scriptDir}/../utils.sh"

function getHandbrake () {
	# Ref: https://launchpad.net/~stebbins/+archive/ubuntu/handbrake-releases
	# Ref: https://websiteforstudents.com/install-handbrake-on-ubuntu-16-04-17-10-18-04/
	# Ref: http://ubuntuhandbook.org/index.php/2018/04/install-handbrake-1-1-ubuntu-18-0417-1016-04/

	sudo apt-get remove --autoremove --yes handbrake-gtk handbrake-cli
	sudo add-apt-repository --remove --yes ppa:stebbins/handbrake-releases

	sudo add-apt-repository --yes ppa:stebbins/handbrake-releases
	sudo apt update
	sudo apt install --yes handbrake-gtk handbrake-cli
}

if [[ "$(getOsVers)" == "16.04" || "$(getOsVers)" == "18.04" || "$(getOsVers)" == "20.04" ]]; then
	getHandbrake
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
