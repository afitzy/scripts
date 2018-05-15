#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")

source "${scriptDir}/../utils.sh"

_VERBOSE=1

if [[ "$(getOsVers)" == "16.04" ]]; then
	# python2
	getPackages "python-pip" "ipython" "python-dateutil"
	getPythonPackages "money" "Babel" "bs4" "lxml" "requests" "enum34" "beautifulsoup4" "pyexcel_ods"

	# python3
	getPackages "python3-pip" "ipython3" "python3-dateutil"
	pip3 install "pyoctopart" "money" # "dateutil"
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
