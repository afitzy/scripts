#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")

source "${scriptDir}/../utils.sh"

_VERBOSE=1

# Ref: https://askubuntu.com/a/1056078
function uninstallHpTools ()
{
	sudo apt-get --yes purge \
		hplip \
		hplip-data \
		hplip-doc \
		hplip-gui \
		hpijs-ppds \
		libsane-hpaio \
		printer-driver-hpcups \
		printer-driver-hpijs

	sudo rm -rf /usr/share/hplip/
	sudo apt-get autoremove --yes
}

function installHpTools ()
{
    sudo apt-get install --yes hplip

    # Fix for https://bugs.launchpad.net/ubuntu/+source/hplip/+bug/1306344
    sudo ln -f -s /usr/share/hplip/sendfax.py /usr/bin/hp-sendfax
}

# Ref: https://developers.hp.com/hp-linux-imaging-and-printing/gethplip
function installHpToolsFromHp3.21.2 ()
{
	wget https://download.sourceforge.net/project/hplip/hplip/3.21.2/hplip-3.21.2.run
	sh hplip-3.21.2.run
}

# Ref: https://developers.hp.com/hp-linux-imaging-and-printing/gethplip
function installHpToolsFromHp3.22.10 ()
{
	# Printing
	wget https://sourceforge.net/projects/hplip/files/hplip/3.22.10/hplip-3.22.10.run
	sh hplip-3.22.10.run

	# Scanning
	wget https://developers.hp.com/sites/default/files/hplip-3.22.10-plugin.run
	sh hplip-3.22.10-plugin.run
}

# Ref: https://developers.hp.com/hp-linux-imaging-and-printing/gethplip
function installHpToolsFromMultiverse ()
{
	 sudo apt install hplip hplip-gui
}

if [[ "$(getOsVers)" == "16.04" || "$(getOsVers)" == "18.04" || "$(getOsVers)" == "20.04" || "$(getOsVers)" == "22.04" || "$(getOsVers)" == "24.04" ]]; then
	uninstallHpTools
fi

if [[ "$(getOsVers)" == "16.04" || "$(getOsVers)" == "18.04" || "$(getOsVers)" == "20.04" ]]; then
	sudo apt-get install --fix-missing --yes sane xsane ksaneplugin
elif [[ "$(getOsVers)" == "22.04" || "$(getOsVers)" == "24.04" ]]; then
	sudo apt-get install --fix-missing --yes sane xsane
fi

# installHpTools
if [[ "$(getOsVers)" == "16.04" || "$(getOsVers)" == "18.04" || "$(getOsVers)" == "20.04" ]]; then
	installHpToolsFromHp3.21.2
elif [[ "$(getOsVers)" == "22.04" ]]; then
	installHpToolsFromHp3.22.10
elif [[ "$(getOsVers)" == "24.04" ]]; then
	# See https://answers.launchpad.net/hplip/+question/817511
	installHpToolsFromMultiverse
fi

# GUI tools
if [[ "$(getOsVers)" == "16.04" || "$(getOsVers)" == "18.04" || "$(getOsVers)" == "20.04" || "$(getOsVers)" == "22.04" || "$(getOsVers)" == "24.04" ]]; then
	sudo apt-get install --yes skanlite
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
