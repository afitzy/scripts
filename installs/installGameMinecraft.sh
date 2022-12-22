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

function installMinecraft () {
	local -r friendlyName="minecraft"

	local -r url="https://launcher.mojang.com/download/Minecraft.deb"
	local urlFilename="${url##*/}"
	urlFilename="${urlFilename%%\?*}"
	local -r filename="${tempdir}/${urlFilename}"

	echo "${friendlyName}: downloading $urlFilename"
	wget --output-document="$filename" "$url"

	sudo apt install --yes "$filename"
}

function uninstallMinecraft () {
	sudo apt --purge remove --yes minecraft-launcher
}




_VERBOSE=1

if [[ "$(getOsVers)" == "16.04" || "$(getOsVers)" == "18.04" || "$(getOsVers)" == "20.04" || "$(getOsVers)" == "22.04" ]]; then
	installMinecraft
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
