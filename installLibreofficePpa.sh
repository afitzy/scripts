#!/bin/bash

source utils.sh

# Remove existing
sudo apt-get remove --purge libreoffice*
sudo apt-get clean
sudo apt-get autoremove

# Add PPA for "LibreOffice fresh", the latest release of the newest series (but no alpha/beta releases)
sudo add-apt-repository ppa:libreoffice/ppa
sudo apt-get update

if [[ "$(getOsVers)" == "16.04" ]]; then
	sudo apt-get install \
		libreoffice-kde\
		libreoffice-calc\
		libreoffice-draw\
		libreoffice-help-en-us\
		libreoffice-math\
		libreoffice-templates\
		libreoffice-writer\
		libreoffice-impress\
		libreoffice-pdfimport\
		libreoffice-style-*
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
