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
	sudo apt-get install language-pack-en language-pack-ca
	sudo apt-get install myspell-en-us myspell-ca
	sudo apt-get install hunspell-en-ca hunspell-ca
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
