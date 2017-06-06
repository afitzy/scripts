#!/bin/bash

source utils.sh

_VERBOSE=1

if [[ "$(getOsVers)" == "16.04" ]]; then
	# pv: Monitor the progress of data through a pipe
	getPackages "pv"

	# fortunes
	getPackages "fortune-mod" "fortunes" "fortunes-min" "fortunes-off" "fortunes-spam" "cookietool"
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
