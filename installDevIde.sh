#!/bin/bash

source utils.sh

_VERBOSE=1

function installAtom () 
{
    sudo add-apt-repository --yes "ppa:webupd8team/atom"
    sudo apt-get update
    getPackages atom
}


if [[ "$(getOsVers)" == "16.04" ]]; then
	installAtom
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
