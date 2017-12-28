#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")

source ../utils.sh

function installCifs () {
	# Client
	sudo apt install -y cifs-utils

	# Server
	sudo apt install -y samba
}

if [[ "$(getOsVers)" == "16.04" ]]; then
	installCifs
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
