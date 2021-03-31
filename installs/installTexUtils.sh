#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")

source "${scriptDir}/../utils.sh"

_VERBOSE=1

# Recommended IDE: Texmaker
# Recommended TeX distribution: TeX Live

if [[ "$(getOsVers)" == "16.04" || "$(getOsVers)" == "18.04" || "$(getOsVers)" == "20.04" ]]; then
	sudo apt-get install --yes texmaker texlive biber latexmk
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi

if [[ "$(getOsVers)" == "16.04" || "$(getOsVers)" == "18.04" ]]; then
	sudo apt-get install --yes texlive-generic-extra
elif [[ "$(getOsVers)" == "20.04" ]]; then
	sudo apt-get install --yes texlive-extra-utils
fi
