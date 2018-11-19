#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")

source "${scriptDir}/../utils.sh"

function removeGmpc ()
{
	sudo apt-get remove --purge --yes gmpc*
}

# Note: GMPC has two repositories (which are never updated).
# 1) GMPC Trunk
# 2) GMPC Stable
function installGmpcFromPpa ()
{
	removeGmpc

	# To-do when these PPAs aren't useless
}

function installGmpcFromMultiverse ()
{
	removeGmpc
	sudo apt-get update
	sudo apt-get install --yes gmpc gmpc-plugins mpd
}

_VERBOSE=1
if [[ "$(getOsVers)" == "16.04" || "$(getOsVers)" == "18.04" ]]; then
	installGmpcFromMultiverse
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
