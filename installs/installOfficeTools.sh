#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")

source "${scriptDir}/../utils.sh"

function installLibreofficePpa ()
{
    # Remove existing
    sudo apt-get remove --purge libreoffice*
    sudo apt-get clean
    sudo apt-get autoremove

    # Add PPA for "LibreOffice fresh", the latest release of the newest series (but no alpha/beta releases)
    sudo add-apt-repository --yes ppa:libreoffice/ppa
    sudo apt-get update

    sudo apt-get --yes install \
        libreoffice-calc \
        libreoffice-draw \
        libreoffice-kde \
        libreoffice-impress \
        libreoffice-help-en-us \
        libreoffice-math \
        libreoffice-pdfimport \
        libreoffice-style-* \
        libreoffice-templates \
        libreoffice-writer

}

if [[ "$(getOsVers)" == "16.04" ]]; then
	installLibreofficePpa
	getPackages "zim"
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
