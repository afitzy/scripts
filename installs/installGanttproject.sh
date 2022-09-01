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

# Last version before cloud capabilities were added
function getGanttProject2.8.11 () {
	# Uninstall existing version
	sudo apt-get remove --yes ganttproject

	local url="http://www.ganttproject.biz/dl/2.8.11/lin"
	local filename="ganttproject.deb"
	local filenameAbs="${tempdir}/${filename}"

	wget \
		--directory-prefix="$tempdir" \
		--output-document="$filenameAbs" \
		"$url"

	sudo dpkg --install "$filenameAbs"  | log
}

# ganttproject3.2 is super-buggy. Strongly suggest not to use it.
function getGanttProject3.2 () {
	# Uninstall existing version
	sudo apt-get remove --yes ganttproject

	local url="https://github.com/bardsoftware/ganttproject/releases/download/ganttproject-3.2.3200/ganttproject_3.2.3230-1_all.deb"
	local filename="ganttproject_3.2.3230-1_all.deb"
	local filenameAbs="${tempdir}/${filename}"

	wget \
		--directory-prefix="$tempdir" \
		--output-document="$filenameAbs" \
		"$url"

	sudo dpkg --install "$filenameAbs"  | log
}

if [[ "$(getOsVers)" == "16.04" || "$(getOsVers)" == "18.04" || "$(getOsVers)" == "20.04" ]]; then
	getGanttProject2.8.11
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
