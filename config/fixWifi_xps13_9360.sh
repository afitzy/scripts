#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")

tempdir=$(mktemp -d)

# Function to cleanup
function cleanup () {
	log "Deleting temp directory: $tempdir"
	rm -rf "$tempdir"
}
trap cleanup EXIT

# Note: 16.04 is using this:
# 	ath10k_pci 0000:3a:00.0: firmware ver WLAN.RM.4.4.1-00079-QCARMSWPZ-1 api 6 features wowlan,ignore-otp crc32 fd869beb
# Ref: https://askubuntu.com/a/773598/271027
# Ref: Ubuntu 16.04 driver bug: https://bugs.launchpad.net/ubuntu/+source/linux/+bug/1436940
function replaceWirelessDriver () {
	local friendlyName="Wireless card driver fix. Use only on the DELL XPS13 9360"

	echo "${friendlyName}: checking current version"
	lspci | grep -i net

	echo "${friendlyName}: removing current driver"
	sudo cp -r /lib/firmware/ath10k/QCA6174{,_BACKUP_${dateStamp}}

	local url="https://github.com/kvalo/ath10k-firmware/archive/master.zip"
	local filename="${url##*/}"
	local filenameAbs="${tempdir}/${filename}"
	wget \
		--directory-prefix="$tempdir" \
		"$url"

	pushd "$tempdir"
	unzip master.zip

	echo "${friendlyName}: installing new driver"
	sudo cp \
		ath10k-firmware-master/QCA6174/hw3.0/4.4.1/firmware-6.bin_WLAN.RM.4.4.1-00140-QCARMSWPZ-1 \
		/lib/firmware/ath10k/QCA6174/hw3.0/firmware-6.bin

	sudo cp \
		ath10k-firmware-master/QCA6174/hw3.0/4.4.1/board-2.bin \
		/lib/firmware/ath10k/QCA6174/hw3.0/

	sudo cp \
		ath10k-firmware-master/QCA6174/hw3.0/4.4.1/board.bin \
		/lib/firmware/ath10k/QCA6174/hw3.0/

	sudo cp \
		ath10k-firmware-master/QCA6174/hw3.0/4.4.1/firmware-4.bin_WLAN.RM.2.0-00180-QCARMSWPZ-1 \
		/lib/firmware/ath10k/QCA6174/hw3.0/firmware-4.bin

	echo "${friendlyName}: reload drivers"
	sudo modprobe -r ath10k_pci ath10k_core
	sudo modprobe ath10k_pci
	sudo modprobe ath10k_core

	echo "${friendlyName}: done"
}

_VERBOSE=1

if [[ "$(getOsVers)" == "18.04" ]]; then
	replaceWirelessDriver
else
	echo "Unrecognized OS version. Exiting."
fi
