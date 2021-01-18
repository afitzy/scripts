#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")

source "${scriptDir}/../utils.sh"


function installDolphin()
{
	srcDir="dolphin"

	sudo apt-get --yes install --no-install-recommends ca-certificates qtbase5-dev qtbase5-private-dev git cmake make gcc g++ pkg-config libavcodec-dev libavformat-dev libavutil-dev libswscale-dev libxi-dev libxrandr-dev libudev-dev libevdev-dev libsfml-dev libminiupnpc-dev libmbedtls-dev libcurl4-openssl-dev libhidapi-dev libsystemd-dev libbluetooth-dev libasound2-dev libpulse-dev libpugixml-dev libbz2-dev libzstd-dev liblzo2-dev libpng-dev libusb-1.0-0-dev gettext

	pushd /usr/local/src
	sudo mkdir "$srcDir"
	sudo chown -R "$USER" "$srcDir"
	sudo chmod 755 "$srcBin"

	pushd "$srcDir"
	git clone https://github.com/dolphin-emu/dolphin.git dolphin-emu
	pushd dolphin-emu

	# Checkout a specific tag
	# git checkout tags/4.0.2

	mkdir Build && cd Build
	cmake ..
	make -j$(nproc)
	sudo make install
}

if [[ "$(getOsVers)" == "20.04" || "$(getOsVers)" == "18.04" ]]; then
	installDolphin
else
	echo "Unrecognized OS version. Not installing."
fi
