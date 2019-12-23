#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")

source "${scriptDir}/../utils.sh"

_VERBOSE=1

if [[ "$(getOsVers)" == "16.04" || "$(getOsVers)" == "18.04" ]]; then
	# GUI tools: editors
	sudo apt-get install --yes gimp

	# GUI tools: viewers (primarily)
	sudo apt-get install --yes nomacs

	# CLI tools
	sudo apt-get install --yes pdftk imagemagick exiftool mediainfo mediainfo-gui
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
