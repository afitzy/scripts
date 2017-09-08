#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")

source utils.sh
_VERBOSE=1


# Add "Compress/Extract Here" context menu
function createExtractHereDesktopFile () {
	local serviceTypesDir="/usr/share/kde4/servicetypes"
	local serviceMenuDir="/usr/share/kservices5/ServiceMenus"
	local desktopFilename="konqpopupmenuplugin.desktop"
	local desktopFile="${serviceMenuDir}/${desktopFilename}"
	if [[ ! -e "$desktopFile" ]]; then
		sudo ln -s ${serviceTypesDir}/${desktopFilename} ${serviceMenuDir}
	else
		log "Skipping creation of \"$desktopFile\", since it already exists."
	fi
}

# Add "copy as path" context menu
function createCopyAsPathDesktopFile () {
	local serviceMenuDir="/usr/share/kservices5/ServiceMenus"
	local desktopFilename="copyaspath.desktop"
	local desktopFile="${serviceMenuDir}/${desktopFilename}"

	if [[ ! -e "$desktopFile" ]]; then
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
	createExtractHereDesktopFile
	createCopyAsPathDesktopFile
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
