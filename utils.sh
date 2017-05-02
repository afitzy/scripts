#!/bin/bash

# Function to conditionally print to terminal
function log () {
	if [[ $_VERBOSE -eq 1 ]]; then
		if [ -n "$1" ]; then
			IN="$@"
		else
			# This reads a string from stdin and stores it in a variable called IN
			while read INPUT; do
				IN+="$INPUT\n"
			done
		fi
		if [ ! -z "$IN" ]; then
			echo -e "$IN"
		fi
	fi
	unset IN
}

# Verify that the required package has been installed
# Ref: http://stackoverflow.com/a/10439058
function getPackage () {
	local package="$1"
	if [ $(dpkg-query -W -f='${Status}' "$package" 2>/dev/null | grep -c "ok installed") -eq 0 ]; then
		log "Package ${package} not installed. Installing it now."
		sudo apt-get --force-yes --yes install "${package}"
	fi
}

# Verify that the required package has been installed
function getPackages () {
	log "Verifying and installing these packages if needed: $@"
	for p in "$@"; do
		getPackage "$p"
	done
}

function getOsVers () {
	echo $(lsb_release -r | grep -oP "[0-9]+[.][0-9]+")
}

function getPythonPackage () {
	local package="$1"
	local piplist="$(pip list 2>/dev/null)"
	if [[ "$piplist" != *"$package"* ]]; then
		log "Python package ${package} not installed. Installing it now"
		pip install "$package"
	fi
}

function verifyContinue () {
	if [[ $_INTERACTIVE -eq 1 ]]; then
		read -p "Do you want to continue? [y/n] " -n 1 -r
		echo
		if [[ ! $REPLY =~ ^[Yy]$ ]] ; then
			[[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
		fi
	fi
}
