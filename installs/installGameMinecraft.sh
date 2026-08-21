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

function patchMinecraftDebFor2604 () {
	local -r sourceFilename="$1"
	local -r unpackDir="${tempdir}/minecraft-deb"
	local -r patchedFilename="${tempdir}/Minecraft-ubuntu-26.04.deb"

	echo "minecraft: patching launcher package dependencies for Ubuntu 26.04"

	mkdir -p "$unpackDir"
	dpkg-deb --extract "$sourceFilename" "$unpackDir"
	dpkg-deb --control "$sourceFilename" "${unpackDir}/DEBIAN"

	if ! grep -q 'libgdk-pixbuf2.0-0' "${unpackDir}/DEBIAN/control"; then
		echo "minecraft: expected legacy libgdk-pixbuf dependency was not found; refusing to modify package"
		return 1
	fi

	sed -i 's/libgdk-pixbuf2\.0-0/libgdk-pixbuf-2.0-0/g' "${unpackDir}/DEBIAN/control"
	dpkg-deb --build "$unpackDir" "$patchedFilename"

}

function installMinecraft () {
	local -r friendlyName="minecraft"

	local -r url="https://launcher.mojang.com/download/Minecraft.deb"
	local urlFilename="${url##*/}"
	urlFilename="${urlFilename%%\?*}"
	local -r filename="${tempdir}/${urlFilename}"
	local installFilename="$filename"

	echo "${friendlyName}: downloading $urlFilename"
	wget --output-document="$filename" "$url"
	chmod 644 "$filename"

	if [[ "$(getOsVers)" == "26.04" ]]; then
		echo "${friendlyName}: installing Ubuntu 26.04 dependencies"
		sudo apt-get update
		sudo apt-get install --yes libgdk-pixbuf-2.0-0

		patchMinecraftDebFor2604 "$filename" || return 1
		installFilename="${tempdir}/Minecraft-ubuntu-26.04.deb"
	fi

	echo "${friendlyName}: installing"
	sudo apt install --yes "$installFilename"
}

function uninstallMinecraft () {
	local -r friendlyName="minecraft"
	echo "${friendlyName}: uninstalling"
	sudo apt --purge remove --yes minecraft-launcher
}




_VERBOSE=1
if [[ "$(getOsVers)" == "16.04" || "$(getOsVers)" == "18.04" || "$(getOsVers)" == "20.04" || "$(getOsVers)" == "22.04" || "$(getOsVers)" == "24.04" || "$(getOsVers)" == "26.04" ]]; then
	installMinecraft
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
