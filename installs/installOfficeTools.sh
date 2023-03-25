#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")

source "${scriptDir}/../utils.sh"

function installLibreofficePpa ()
{
    # Remove existing
    sudo apt-get remove --purge --yes libreoffice*
    sudo apt-get clean --yes
    sudo apt-get autoremove --yes

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

	# Workaround for transparent menu problem, per
	# https://ask.libreoffice.org/en/question/201771/menus-are-transparent-after-recent-update/
	sudo apt-get --yes install libreoffice-gtk*
	sudo apt-get --yes install libreoffice-kde*

}

# Libreoffice
if [[ "$(getOsVers)" == "16.04" || "$(getOsVers)" == "18.04" || "$(getOsVers)" == "20.04" ]]; then
	installLibreofficePpa
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi

if [[ "$(getOsVers)" == "16.04" || "$(getOsVers)" == "18.04" || "$(getOsVers)" == "20.04" || "$(getOsVers)" == "22.04" ]]; then
	sudo apt-get install --yes zim
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
