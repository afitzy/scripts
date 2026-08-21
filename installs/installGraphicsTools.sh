#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")

source "${scriptDir}/../utils.sh"

_VERBOSE=1

if [[ "$(getOsVers)" == "16.04" || "$(getOsVers)" == "18.04" || "$(getOsVers)" == "20.04" || "$(getOsVers)" == "22.04" || "$(getOsVers)" == "24.04" ]]; then
	# GUI tools: editors
	sudo apt-get install --yes gimp

	# GUI tools: viewers (primarily)
	sudo apt-get install --yes nomacs
	# CLI tools
	sudo apt-get install --yes pdftk imagemagick exiftool mediainfo mediainfo-gui
elif [[ "$(getOsVers)" == "26.04" ]]; then
	# GUI tools: editors
	sudo apt-get install --yes gimp

	# GUI tools: viewers (primarily)
	sudo apt-get install --yes nomacs
	# CLI tools
	# Ubuntu 26.04 provides pdftk via pdftk-java and ExifTool via libimage-exiftool-perl.
	sudo apt-get install --yes pdftk-java imagemagick libimage-exiftool-perl mediainfo mediainfo-gui
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
