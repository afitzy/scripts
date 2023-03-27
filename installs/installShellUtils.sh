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

if [[ "$(getOsVers)" == "16.04" || "$(getOsVers)" == "18.04" || "$(getOsVers)" == "20.04" || "$(getOsVers)" == "22.04" ]]; then
	# pv: Monitor the progress of data through a pipe
	sudo apt-get install --yes pv

	# Network monitoring
	sudo apt-get install --yes nethogs

	# File compression
	sudo apt-get install --yes unrar

	# fortunes
	sudo apt-get install --yes fortune-mod fortunes fortunes-min fortunes-off fortunes-spam cookietool

	# Colored-df
	sudo apt-get install --yes dfc

	# Colored diff
	sudo apt-get install --yes colordiff

	# text processing
	sudo apt-get install --yes wdiff

	# Prints a directory tree
	sudo apt-get install --yes tree
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
