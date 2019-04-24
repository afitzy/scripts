#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")

source "${scriptDir}/../utils.sh"

_VERBOSE=1

function installAtom ()
{
    sudo add-apt-repository --yes "ppa:webupd8team/atom"
    sudo apt-get update
    getPackages atom
}


if [[ "$(getOsVers)" == "16.04" || "$(getOsVers)" == "18.04" ]]; then
	installAtom
	getPackages "cscope"

	# Visual diff
	getPackages "meld"

	# Static code analysis
	getPackages "cppcheck"

	# Code formatters
	pip install jsbeautifier
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
