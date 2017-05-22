#!/bin/bash

source utils.sh

tempdir=$(mktemp -d)

# Function to cleanup
function cleanup () {
        log "Deleting temp directory: $tempdir"
        rm -rf "$tempdir"
}
trap cleanup EXIT

function installGoogleEarth ()
{
	# Remove old versions
	sudo dpkg -P google-earth-stable
	sudo rm -rf /opt/google/earth/free

	# pre-requisites
	getPackages "lsb-core"

	local url="http://dl.google.com/dl/earth/client/current/google-earth-stable_current_amd64.deb"
	local filename="${url##*/}"
	local filenameAbs="${tempdir}/${filename}"
	wget \
    --directory-prefix="$tempdir" \
		"$url"
	sudo dpkg --install "$filenameAbs"  | log
}

_VERBOSE=1
if [[ "$(getOsVers)" == "16.04" ]]; then
	installGoogleEarth
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
