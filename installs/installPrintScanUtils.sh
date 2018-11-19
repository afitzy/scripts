#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")

source "${scriptDir}/../utils.sh"

_VERBOSE=1

function installHpTools ()
{
    sudo apt-get install --yes hplip

    # Fix for https://bugs.launchpad.net/ubuntu/+source/hplip/+bug/1306344
    sudo ln -f -s /usr/share/hplip/sendfax.py /usr/bin/hp-sendfax
}

if [[ "$(getOsVers)" == "16.04" || "$(getOsVers)" == "18.04" ]]; then
	installHpTools
	sudo apt-get install --yes xsane ksaneplugin

	# GUI tools
	sudo apt-get install --yes skanlite
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
