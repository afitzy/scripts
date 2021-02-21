#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")

source "${scriptDir}/../utils.sh"


# SNES emulator snes9x
# Not as accurate as Higan, but difference isn't super noticeable.
function installSnes9x()
{
	sudo apt-get install flatpak
	flatpak remote-add --if-not-exists flathub https://flathub.org/repo/flathub.flatpakrepo
	flatpak install flathub com.snes9x.Snes9x
}

# SNES (and others) emulator
# High accuracy and high CPU demand
function installHigan()
{
	srcDir="higan-emu"
	gitDir="higan"

	sudo apt-get --yes install build-essential libgtk2.0-dev libpulse-dev \
		mesa-common-dev libgtksourceview2.0-dev libcairo2-dev \
		libxv-dev libao-dev libopenal-dev libudev-dev \
		libsdl2-dev # requirement of newer versions of higan

	pushd /usr/local/src
	sudo mkdir "$srcDir"
	sudo chown -R "$USER" "$srcDir"
	sudo chmod 755 "$srcDir"

	pushd "$srcDir"
	git clone https://github.com/higan-emu/higan.git "$gitDir"
	pushd "$gitDir"

	# https://github.com/higan-emu/higan/releases
	git checkout tags/v110
	make -C higan
	make -C icarus

	make -C higan install
	make -C icarus install
	[ -d shaders ] && make -C shaders install

	for run in {1..3}; do popd; done
}

function uninstallHigan()
{
	srcDir="higan-emu"
	gitDir="higan"

	pushd "/usr/local/src/${srcDir}/${gitDir}"
	make -C higan uninstall
	make -C icarus uninstall
	popd
}

# Nintendo Wii emulator
function installDolphin()
{
	srcDir="dolphin"

	sudo apt-get --yes install --no-install-recommends ca-certificates qtbase5-dev qtbase5-private-dev git cmake make gcc g++ pkg-config libavcodec-dev libavformat-dev libavutil-dev libswscale-dev libxi-dev libxrandr-dev libudev-dev libevdev-dev libsfml-dev libminiupnpc-dev libmbedtls-dev libcurl4-openssl-dev libhidapi-dev libsystemd-dev libbluetooth-dev libasound2-dev libpulse-dev libpugixml-dev libbz2-dev libzstd-dev liblzo2-dev libpng-dev libusb-1.0-0-dev gettext

	pushd /usr/local/src
	sudo mkdir "$srcDir"
	sudo chown -R "$USER" "$srcDir"
	sudo chmod 755 "$srcDir"

	pushd "$srcDir"
	git clone https://github.com/dolphin-emu/dolphin.git dolphin-emu
	pushd dolphin-emu

	# Checkout a specific tag
	# git checkout tags/4.0.2

	mkdir Build && cd Build
	cmake ..
	make -j$(nproc)
	sudo make install

	for run in {1..3}; do popd; done
}

if [[ "$(getOsVers)" == "20.04" || "$(getOsVers)" == "18.04" ]]; then
	# installDolphin
	# installHigan # Did not use this. Interface was poor, version I built did not work, and compiled binary I downloaded did not work.
	installSnes9x
else
	echo "Unrecognized OS version. Not installing."
fi
