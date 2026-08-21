#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")

source "${scriptDir}/../utils.sh"



_VERBOSE=1
if [[ "$(getOsVers)" == "16.04" ]]; then
	# KeePassXC is not available in the Ubuntu 16.04 repositories; retain KeePassX for this legacy release.
	sudo apt-get install --yes keepassx
elif [[ "$(getOsVers)" == "18.04" || "$(getOsVers)" == "20.04" || "$(getOsVers)" == "22.04" || "$(getOsVers)" == "24.04" ]]; then
	sudo apt-get install --yes keepassxc
elif [[ "$(getOsVers)" == "26.04" ]]; then
	# In Ubuntu 26.04 keepassxc is a transitional package; install the full package explicitly.
	sudo apt-get install --yes keepassxc-full
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
