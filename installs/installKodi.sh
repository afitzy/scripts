#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")

source "${scriptDir}/../utils.sh"

function removeKodi ()
{
	sudo apt-get update
	sudo apt-get remove --purge kodi*
}

function removeKodiUserFiles ()
{
	rm -r "${USER}/.kodi/"
}

# Note: Kodi maintains three repositories:
# 1) Final release builds: ppa:team-xbmc/ppa
# 2) Betas and release candidates: ppa:team-xbmc/unstable
# 3) Nightly candidates: ppa:team-xbmc/xbmc-nightly
# Ref: https://www.ghacks.net/2018/02/11/installing-kodi-using-ubuntu-based-systems/
function installKodiFromPpa ()
{
	removeKodi

    # prerequisites
    sudo apt-get remove python-cryptography
    sudo apt-get install python-pip
    pip install --user --upgrade cryptography
	sudo apt-get install software-properties-common

    # install Kodi
	sudo add-apt-repository ppa:team-xbmc/ppa
	sudo apt update
	sudo apt install kodi

    # start kodi at login
    #cp /usr/share/applications/kodi.desktop ${USER}/.config/autostart
}


_VERBOSE=1
if [[ "$(getOsVers)" == "16.04" || "$(getOsVers)" == "18.04" || "$(getOsVers)" == "20.04" ]]; then
	installKodiFromPpa
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
