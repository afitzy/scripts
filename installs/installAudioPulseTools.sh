#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")

source "${scriptDir}/../utils.sh"

_VERBOSE=1

if [[ "$(getOsVers)" == "16.04" ]]; then
	# Set to...
	# 1) Enable network access to local sound devices
	# 2) Don't require authentication
	getPackages "paprefs"

	# Pulse mixer
	getPackages "pavucontrol"
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
