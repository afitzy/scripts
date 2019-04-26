#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")

source "${scriptDir}/../utils.sh"

tempdir=$(mktemp -d)

# Function to cleanup
function cleanup () {
	log "Deleting temp directory: $tempdir"
	rm -rf "$tempdir"
}
trap cleanup EXIT


_VERBOSE=1

function getGanttProject () {
	# Uninstall existing version
	sudo apt-get remove --yes ganttproject

	local url="http://www.ganttproject.biz/dl/2.8.10/lin"
	local filename="ganttproject.deb"
	local filenameAbs="${tempdir}/${filename}"

	wget \
		--directory-prefix="$tempdir" \
		--output-document="$filenameAbs" \
		"$url"

	sudo dpkg --install "$filenameAbs"  | log
}

if [[ "$(getOsVers)" == "16.04" || "$(getOsVers)" == "18.04" ]]; then
	getGanttProject
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
