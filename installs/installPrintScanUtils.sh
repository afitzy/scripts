#!/bin/bash

source utils.sh

_VERBOSE=1

function installHpTools ()
{
    getPackages "hplip"

    # Fix for https://bugs.launchpad.net/ubuntu/+source/hplip/+bug/1306344
    sudo ln -f -s /usr/share/hplip/sendfax.py /usr/bin/hp-sendfax
}

if [[ "$(getOsVers)" == "16.04" ]]; then
	installHpTools
	getPackages "xsane" "ksaneplugin"
	
	# GUI tools
	getPackages "skanlite"
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
