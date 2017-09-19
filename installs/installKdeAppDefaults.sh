#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")

source ../utils.sh
_VERBOSE=1



if [[ "$(getOsVers)" == "16.04" ]]; then
	userAppDefault="${HOME}/.local/share/applications/mimeapps.list"
	systemAppDefault="${HOME}/.config/mimeapps.list"
	perl -pi -e "s/(?<=text\/html=).*/firefox.desktop/" "$userAppDefault"
	perl -pi -e "s/(?<=text\/html=).*/firefox.desktop/" "$systemAppDefault"
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
