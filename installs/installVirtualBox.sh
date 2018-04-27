#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")

source "${scriptDir}/../utils.sh"

function removeVirtualBox ()
{
	# Remove existing
	sudo apt-get remove --purge virtualbox*
	sudo apt-get clean
	sudo apt-get autoremove
}

function installVitualBoxFromMultiverse ()
{
	removeVirtualBox
	sudo apt-get install --yes virtualbox virtualbox-ext-pack virtualbox-guest-* virtualbox-qt
}

# The binaries in this repository are all released under the VirtualBox Personal
# Use and Evaluation License (PUEL). By downloading, you agree to the terms and
# conditions of that license.
# Ref: https://www.ubuntuupdates.org/ppa/virtualbox.org_contrib
function installVirtualBoxFromOracle ()
{
	removeVirtualBox

	# Add Oracle key
	local url='http://download.virtualbox.org/virtualbox/debian/oracle_vbox_2016.asc'
	wget --quiet --output-document=- ${url} | sudo apt-key add -

	# Set up repository
	ubuntuRelease=$(lsb_release -cs)
	sudo sh -c "echo 'deb http://download.virtualbox.org/virtualbox/debian ${ubuntuRelease} non-free contrib' > /etc/apt/sources.list.d/virtualbox.org.list"

	sudo apt-get update
	sudo apt-get install --yes virtualbox-5.2 virtualbox-ext-pack
	# virtualbox-ext-pack virtualbox-guest-* virtualbox-qt
}


_VERBOSE=1
if [[ "$(getOsVers)" == "16.04" ]]; then
	installVirtualBoxFromOracle
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
