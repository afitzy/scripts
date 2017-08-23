#!/bin/bash

source utils.sh

function sshConfig () {
	# SSH starts at boot time, not user login
	# NOTE: Network needs to be configured to start at boot time, else this won't work
	sudo update-rc.d ssh defaults
}

if [[ "$(getOsVers)" == "16.04" ]]; then
	getPackages "ssh"
	sshConfig
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
