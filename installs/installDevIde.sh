#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")

source "${scriptDir}/../utils.sh"

_VERBOSE=1

function installAtom16.04 ()
{
    wget -qO - https://packagecloud.io/AtomEditor/atom/gpgkey | sudo apt-key add -
    sudo sh -c 'echo "deb [arch=amd64] https://packagecloud.io/AtomEditor/atom/any/ any main" > /etc/apt/sources.list.d/atom.list'
    sudo apt-get update
    sudo apt-get install --yes atom
}

function installAtom22.04 ()
{
	sudo apt update && sudo apt upgrade -y
	sudo apt install software-properties-common apt-transport-https wget -ysudo apt install software-properties-common apt-transport-https wget -y
	wget -O- https://packagecloud.io/AtomEditor/atom/gpgkey | gpg --dearmor | sudo tee /usr/share/keyrings/atom.gpg
	echo "deb [arch=amd64 signed-by=/usr/share/keyrings/atom.gpg] \
	https://packagecloud.io/AtomEditor/atom/any/ any main" \
	| sudo tee /etc/apt/sources.list.d/atom.list
	sudo apt update
	sudo apt install atom -y
	atom --version
}

if [[ "$(getOsVers)" == "16.04" || "$(getOsVers)" == "18.04" || "$(getOsVers)" == "20.04" || "$(getOsVers)" == "22.04" ]]; then
	sudo snap install --classic atom
	sudo apt-get install --yes cscope

	# Visual diff
	sudo apt-get install --yes meld

	# Static code analysis
	# sudo apt-get install --yes cppcheck

	# Code formatters
	pip install jsbeautifier
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
