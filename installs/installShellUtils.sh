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

function installDropboxCli ()
{
	# Ref: http://www.dropboxwiki.com/tips-and-tricks/install-dropbox-in-an-entirely-text-based-linux-environment#debianubuntu

	cd ${HOME}

	# Stable 64-bit
	wget -O dropbox.tar.gz "http://www.dropbox.com/download/?plat=lnx.x86_64"

	# Sanity check
	tar -tzf dropbox.tar.gz

	tar -xvzf dropbox.tar.gz

	${HOME}/.dropbox-dist/dropboxd &

	# TODO: Add hooks to run automatically at system boot-up
}


_VERBOSE=1

if [[ "$(getOsVers)" == "16.04" ]]; then
	# pv: Monitor the progress of data through a pipe
	getPackages "pv"

	# Network monitoring
	getPackages "nethogs"

	# File compression
	getPackages "unrar"

	# fortunes
	getPackages "fortune-mod" "fortunes" "fortunes-min" "fortunes-off" "fortunes-spam" "cookietool"

	# Colored-df
	getPackages "dfc"

	# Colored diff
	getPackages "colordiff"

	# text processing
	getPackages "wdiff"

	# Prints a directory tree
	getPackages "tree"
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
