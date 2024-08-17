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

if [[ "$(getOsVers)" == "16.04" || "$(getOsVers)" == "18.04" || "$(getOsVers)" == "20.04" ]]; then
	sudo apt-get install --yes \
		language-pack-en \
		language-pack-ca \
		\
		myspell-en-us \
		myspell-ca \
		\
		hunspell-en-ca \
		hunspell-ca
elif [[ "$(getOsVers)" == "22.04" || "$(getOsVers)" == "24.04" ]]; then
	sudo apt-get install --yes \
		language-pack-en \
		language-pack-ca \
		\
		hunspell-en-ca \
		hunspell-en-us \
		hunspell-ca
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
