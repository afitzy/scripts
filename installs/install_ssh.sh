#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")

source "${scriptDir}/../utils.sh"

function sshConfig () {
	# SSH starts at boot time, not user login
	# NOTE: Network needs to be configured to start at boot time, else this won't work
	sudo update-rc.d ssh defaults
}

if [[ "$(getOsVers)" == "16.04" ]]; then
	getPackages "ssh"
	sshConfig

	# Needed for X11 tunneling
	sudo apt-get install xauth
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
