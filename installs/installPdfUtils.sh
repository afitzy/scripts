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

_VERBOSE=1

if [[ "$(getOsVers)" == "16.04" ]]; then
	sudo apt-get install --yes ocaml unpaper tesseract
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
