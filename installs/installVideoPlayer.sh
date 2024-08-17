#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")

source "${scriptDir}/../utils.sh"

_VERBOSE=1

if [[ "$(getOsVers)" == "16.04" || "$(getOsVers)" == "18.04" || "$(getOsVers)" == "20.04" ]]; then
	sudo apt-get install --yes smplayer smplayer-themes smtube
elif [[ "$(getOsVers)" == "22.04" || "$(getOsVers)" == "24.04" ]]; then
	sudo snap install smplayer
	sudo snap connect smplayer:removable-media
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
