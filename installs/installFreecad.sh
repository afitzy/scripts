#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")

source "${scriptDir}/../utils.sh"

# Function to cleanup
function cleanup () {
	log "Deleting temp directory: $tempdir"
	rm -rf "$tempdir"
}
trap cleanup EXIT

function getFreecadPpa () {
	local friendlyName="FreeCAD"

	echo "${friendlyName}: removing previous installation"
	sudo apt-get remove --purge --yes freecad
	sudo apt-get clean

	echo "${friendlyName}: adding PPA"
	sudo add-apt-repository --yes ppa:freecad-maintainers/freecad-stable
	sudo apt-get update

	echo "${friendlyName}: installing"
	sudo apt-get install --yes freecad

	echo "${friendlyName}: done"
}

_VERBOSE=1

if [[ "$(getOsVers)" == "16.04" || "$(getOsVers)" == "18.04" || "$(getOsVers)" == "20.04" ||  "$(getOsVers)" == "22.04" || "$(getOsVers)" == "24.04" ]]; then
	getFreecadPpa
else
	echo "Unrecognized OS version. Exiting."
fi
