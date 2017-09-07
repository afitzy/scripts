#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")

source utils.sh
_VERBOSE=1


function createCopyAsPathDesktopFile () {
	local serviceMenuDir="/usr/share/kservices5/ServiceMenus/"
	local desktopFilename="copyaspath.desktop"
	local desktopFile="${serviceMenuDir}/${desktopFilename}"

	if [[ ! -f "$desktopFile" ]]; then
		log "Creating \"$desktopFile\""

sudo tee "$desktopFile" > /dev/null <<EOL
# Written by ${scriptName} on ${dateStamp}
[Desktop Entry]
Type=Service
Icon=editcopy
Actions=copyaspath
X-KDE-Priority=TopLevel
ServiceTypes=KonqPopupMenu/Plugin,application/octet-stream
[Desktop Action copyaspath]
Exec=echo "%F" | tr -d '\n' | xclip -selection clipboard
Icon=editcopy
Name=Copy as path
EOL

	else
		log "Skipping creation of \"$desktopFile\", since it already exists."
	fi
}


if [[ "$(getOsVers)" == "16.04" ]]; then
	# Add "Compress/Extract Here" context menu
	sudo ln -s /usr/share/kde4/servicetypes/konqpopupmenuplugin.desktop /usr/share/kservices5/ServiceMenus/

	# Add "copy as path" context menu
	createCopyAsPathDesktopFile
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
