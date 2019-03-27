#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")

source "${scriptDir}/../utils.sh"

function removeVirtualBox ()
{
	local -r friendlyName="VirtualBox"
	echo "${friendlyName}: removing previous installation"
	sudo apt-get remove --purge virtualbox*
	sudo apt-get clean
	sudo apt-get autoremove --yes
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
	local -r removeOldVersion="$1"
	local -r version="${2:-1}"

	local -r friendlyName="VirtualBox"

	if [[ "$removeOldVersion" -eq 1 ]]; then
		removeVirtualBox
	fi

	echo "${friendlyName}: downloading Oracle key"
	local url='http://download.virtualbox.org/virtualbox/debian/oracle_vbox_2016.asc'
	wget --quiet --output-document=- ${url} | sudo apt-key add -

	echo "${friendlyName}: setting up repository"
	ubuntuRelease=$(lsb_release -cs)
	sudo sh -c "echo 'deb http://download.virtualbox.org/virtualbox/debian ${ubuntuRelease} non-free contrib' > /etc/apt/sources.list.d/virtualbox.org.list"

	echo "${friendlyName}: refreshing multiverse"
	sudo apt-get update

	echo "${friendlyName}: installing"
	sudo apt-get install --yes virtualbox-${version}

	# These conflict with virtualbox-5.2
	# sudo apt-get install --yes virtualbox-ext-pack virtualbox-guest-* virtualbox-qt
}

function installVirtualBoxFromOracle_v5.2 () {
	local -r removeOldVersion=1
	local -r version=5.2
	installVirtualBoxFromOracle "$removeOldVersion" "$version"
}

function installVirtualBoxFromOracle_v6.0 () {
	local -r removeOldVersion=1
	local -r version=6.0
	installVirtualBoxFromOracle "$removeOldVersion" "$version"
}

_VERBOSE=1
if [[ "$(getOsVers)" == "16.04" || "$(getOsVers)" == "18.04" ]]; then
	installVirtualBoxFromOracle_v6.0
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
