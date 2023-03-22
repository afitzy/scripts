#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")

source "${scriptDir}/../utils.sh"

_VERBOSE=1

function installSilan ()
{
	if [[ "$(getOsVers)" == "16.04" || "$(getOsVers)" == "18.04" || "$(getOsVers)" == "20.04" ]]; then
		sudo apt-get install --yes silan
	else
		echo "Unrecognized OS version. Not installed pre-requisites."
	fi
}


# GUI tools
sudo apt-get install --yes audacity

# CLI tools
installSilan
sudo apt-get install --yes mp3val
