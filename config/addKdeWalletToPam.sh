#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")
tempdir=$(mktemp -d)

source "${scriptDir}/../utils.sh"

# Function to cleanup
function cleanup () {
	log "Deleting temp directory: $tempdir"
	rm -rf "$tempdir"
}
trap cleanup EXIT

# Ref: https://github.com/nextcloud/desktop/issues/4814
# 	Sub-ref: https://wiki.archlinux.org/title/KDE_Wallet
function addKdeWalletToPam () {
	local -r friendlyName="KDE Wallet config with PAM"

	echo "${friendlyName}: installing pre-requisites"
	sudo apt-get --install-suggests install libpam-kwallet5

	echo "${friendlyName}: configuring"
	# add the following lines to /etc/pam.d/login
	# auth      optional pam_kwallet5.so
	# session   optional pam_kwallet5.s0 auto_start force_run
}




_VERBOSE=1

if [[ "$(getOsVers)" == "16.04" || "$(getOsVers)" == "18.04" || "$(getOsVers)" == "20.04" || "$(getOsVers)" == "22.04" ]]; then
	addKdeWalletToPam
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
