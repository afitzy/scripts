#!/bin/bash

source utils.sh

_VERBOSE=1

if [[ "$(getOsVers)" == "16.04" ]]; then
	getPackages "virtualbox" "virtualbox-ext-pack" "virtualbox-guest-*" "virtualbox-qt"
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
