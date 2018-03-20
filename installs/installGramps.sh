#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")
tempdir=$(mktemp -d)

source "${scriptDir}/../utils.sh"

# Function to cleanup
function cleanup () {
	log "Deleting temp directory: $tempdir"
	rm -rf "$tempdir"
}
trap cleanup EXIT

# Install Gramps from GitHub
# https://github.com/gramps-project/gramps
function installGramps () {
	local friendlyName="gramps"

	# Uninstall existing version
	sudo apt-get remove --yes gramps 2>&1 | log

	# Pre-reqs
	sudo apt-get install --yes python3-icu | log

	local url='https://github.com/gramps-project/gramps/releases/download/v4.2.6/python3-gramps_4.2.6_all.deb'
	local urlFilename="${url##*/}"
	urlFilename="${urlFilename%%\?*}"
	local filename="${tempdir}/${urlFilename}"

	echo "${friendlyName}: downloading $urlFilename"

	wget \
		--output-document="$filename" \
		"$url" 2>&1 | while read -r line; do log ; done

	echo "${friendlyName}: installing"
	sudo dpkg --install "$filename" 2>&1 | log

	echo "${friendlyName}: attempting to satisfy unment dependencies"
	sudo apt-get -f --yes install 2>&1 | log

	echo "${friendlyName}: done"
}


_VERBOSE=1

if [[ "$(getOsVers)" == "16.04" ]]; then
	installGramps
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
