#!/bin/bash

source utils.sh

# Remove existing
sudo apt-get remove --purge libreoffice*
sudo apt-get clean
sudo apt-get autoremove

# Add PPA for "LibreOffice fresh", the latest release of the newest series (but no alpha/beta releases)
sudo add-apt-repository --yes ppa:libreoffice/ppa
sudo apt-get update

if [[ "$(getOsVers)" == "16.04" ]]; then
	sudo apt-get --yes install \
		libreoffice-calc\
		libreoffice-draw\
		libreoffice-kde\
		libreoffice-impress\
		libreoffice-help-en-us\
		libreoffice-math\
		libreoffice-pdfimport\
		libreoffice-style-*
		libreoffice-templates\
		libreoffice-writer\
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi