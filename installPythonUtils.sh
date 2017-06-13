#!/bin/bash

source utils.sh

_VERBOSE=1

if [[ "$(getOsVers)" == "16.04" ]]; then
	# python2
	getPackages "python-pip"

	# python3
	getPackages "python3-pip"
	getPythonPackages "pyoctopart"
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
