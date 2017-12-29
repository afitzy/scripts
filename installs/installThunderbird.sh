#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")

source "${scriptDir}/../utils.sh"

_VERBOSE=1

function installThunderbird ()
{
	sudo add-apt-repository -y ppa:ubuntu-mozilla-security/ppa
	sudo apt-get update
	sudo apt-get install thunderbird
}

if [[ "$(getOsVers)" == "16.04" ]]; then
	installThunderbird
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
