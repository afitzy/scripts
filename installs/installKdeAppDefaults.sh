#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")

source ../utils.sh
_VERBOSE=1



if [[ "$(getOsVers)" == "16.04" ]]; then
	appDefaults="${HOME}/.local/share/applications/mimeapps.list"
	perl -pi -e "s/(?<=text\/html=).*/firefox.desktop/" "$appDefaults"
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
