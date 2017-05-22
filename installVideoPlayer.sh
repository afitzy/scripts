#!/bin/bash

source utils.sh

_VERBOSE=1

if [[ "$(getOsVers)" == "16.04" ]]; then
	getPackages "smplayer" "smplayer-themes" "smtube"
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
