#!/bin/bash

source utils.sh

_VERBOSE=1

if [[ "$(getOsVers)" == "16.04" ]]; then
	# GUI tools
	getPackages "audacity"
	
	# CLI tools
	getPackages "silan"
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
