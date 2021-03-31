#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")

source "${scriptDir}/../utils.sh"

_VERBOSE=1

if [[ "$(getOsVers)" == "16.04" || "$(getOsVers)" == "18.04" || "$(getOsVers)" == "20.04" ]]; then
	# python2
	sudo apt-get --yes --ignore-missing install python-pip ipython python-dateutil python-argcomplete python-colorlog

	# Ply is needed by mork (.mab file reader). I use it for Thunderbird.
	sudo apt-get --yes --ignore-missing install python-ply

	getPythonPackages "money" "Babel" "bs4" "lxml" "requests" "enum34" "beautifulsoup4" "pyexcel_ods" "pyexcel_xlsx" "zodbbrowser"

	# python3
	sudo apt-get --yes --ignore-missing install python3-pip ipython3 python3-dateutil python3-colorlog python3-argcomplete
	pip3 install "pyoctopart" "money" # "dateutil"
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
