#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")

source "${scriptDir}/../utils.sh"

_VERBOSE=1

function installPianobar ()
{
	local -r gitHash=$1

	local -r instPrefix="/usr/local"
	local -r binDir="${instPrefix}/bin"
	local -r srcDir="${instPrefix}/src"

	local -r repoAddr="https://github.com/PromyLOPh/pianobar.git"
	local repoName="${repoAddr##*/}"
	local repoName="${repoName%%.*}"

	# Install prereqs
	getPackages "make" "pkg-config"
	getPackages "libao-dev" "libgcrypt20-dev" "libjson-c-dev" "libavcodec-dev" "libavfilter-dev" "libavformat-dev" "libcurl4-gnutls-dev"

	cloneGitRepo "$srcDir" "$repoAddr"

	# Temporary workaround for https://github.com/PromyLOPh/pianobar/issues/614
	git checkout $gitHash

	make clean && make
	sudo make install

	# Copy config script to home dir if it doesn't exist
	local configScriptDir="${HOME}/.config/pianobar/"
	mkdir --parents "$configScriptDir"

	local configScript="$configScriptDir/config"
	if [[ ! -d "$configScript" ]]; then
		cp "contrib/config-example" "$configScript"
	fi

	popd
	popd
}

if [[ "$(getOsVers)" == "16.04" || "$(getOsVers)" == "18.04" ]]; then
	installPianobar e945578ab22912049f1e547ce7b25b01089f7590
elif [[ "$(getOsVers)" == "20.04" || "$(getOsVers)" == "22.04" || "$(getOsVers)" == "24.04" ]]; then
	installPianobar 218f3f84965e648793bcb2b0b9d97de636de01e7
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
