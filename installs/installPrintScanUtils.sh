#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")

source "${scriptDir}/../utils.sh"

_VERBOSE=1

# Ref: https://askubuntu.com/a/1056078
function uninstallHpTools ()
{
	sudo apt-get purge \
		hplip \
		hplip-data \
		hplip-doc \
		hplip-gui \
		hpijs-ppds \
		libsane-hpaio \
		printer-driver-hpcups \
		printer-driver-hpijs

	sudo rm -rf /usr/share/hplip/
	sudo apt-get autoremove
}

function installHpTools ()
{
    sudo apt-get install --yes hplip

    # Fix for https://bugs.launchpad.net/ubuntu/+source/hplip/+bug/1306344
    sudo ln -f -s /usr/share/hplip/sendfax.py /usr/bin/hp-sendfax
}

# Ref: https://developers.hp.com/hp-linux-imaging-and-printing/gethplip
function installHpToolsFromHp ()
{
	wget https://download.sourceforge.net/project/hplip/hplip/3.20.11/hplip-3.20.11.run
	sh hplip-3.20.11.run
}

if [[ "$(getOsVers)" == "16.04" || "$(getOsVers)" == "18.04" ]]; then
	uninstallHpTools

	sudo apt-get install --fix-missing --yes xsane ksaneplugin

	# installHpTools
	installHpToolsFromHp

	# GUI tools
	sudo apt-get install --yes skanlite
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
