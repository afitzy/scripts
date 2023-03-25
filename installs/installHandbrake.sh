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

function getHandbrakeMultiverse () {
	# Ref: https://launchpad.net/~stebbins/+archive/ubuntu/handbrake-releases
	# Ref: https://websiteforstudents.com/install-handbrake-on-ubuntu-16-04-17-10-18-04/
	# Ref: http://ubuntuhandbook.org/index.php/2018/04/install-handbrake-1-1-ubuntu-18-0417-1016-04/

	sudo apt-get remove --autoremove --yes handbrake-gtk handbrake-cli
	sudo add-apt-repository --remove --yes ppa:stebbins/handbrake-releases

	sudo add-apt-repository --yes ppa:stebbins/handbrake-releases
	sudo apt update
	sudo apt install --yes handbrake-gtk handbrake-cli
}

# Installs from a downloaded flatpak file
# This doesn't work yet, as Ubuntu doesn't ship with the flatpak run-time installed and I couldn't easily figure it out
function getHandbrake1.6.1 () {
	local friendlyName="handbrake"

	echo "${friendlyName}: installing flatpak"
	sudo apt install flatpak

	# Off-topic: fix flatpak applications ot respecting KDE Plasma's system-wide dark theme
	flatpak override --user --filesystem=xdg-config/gtk-3.0:ro

	local -r url='https://github.com/HandBrake/HandBrake/releases/download/1.6.1/HandBrake-1.6.1-x86_64.flatpak'
	local urlFilename="${url##*/}"
	urlFilename="${urlFilename%%\?*}"
	local -r filename="${tempdir}/${urlFilename}"

	echo "${friendlyName}: downloading $urlFilename"

	wget \
		--output-document="$filename" \
		"$url" 2>&1 | while read -r line; do log ; done

	local -r checksumStatus=$(echo "2587b74301579ea3c127887d135ed3b8151c72b429e23566d4619771393a9fd4  ${filename}" | sha256sum --check --status)
	if [[ "$checksumStatus" -ne 0 ]]; then
		echo "${friendlyName}: checksum verification failed. Exiting"
		return -1
	fi

	echo "${friendlyName}: installing"
	sudo flatpak install "$filename" 2>&1 | log

	echo "${friendlyName}: done"
}

# Installs from flatpak
function getHandbrakeFlatpak () {
	local friendlyName="handbrake"

	echo "${friendlyName}: installing flatpak"
	sudo apt install flatpak

	# Off-topic: fix flatpak applications ot respecting KDE Plasma's system-wide dark theme
	flatpak override --user --filesystem=xdg-config/gtk-3.0:ro

	# Add flathub multiverse
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo

	echo "${friendlyName}: installing"
	sudo flatpak install fr.handbrake.ghb

	echo "${friendlyName}: done"
}

_VERBOSE=1
if [[ "$(getOsVers)" == "16.04" || "$(getOsVers)" == "18.04" || "$(getOsVers)" == "20.04" ]]; then
	getHandbrakeMultiverse
elif [[ "$(getOsVers)" == "22.04" ]]; then
	getHandbrakeFlatpak
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
