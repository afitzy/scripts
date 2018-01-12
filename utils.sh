#!/bin/bash

_DIR_PREFIX="/usr/local"
_DIR_BIN="${_DIR_PREFIX}/bin"
_DIR_SRC="${_DIR_PREFIX}/src"

# Function to conditionally print to terminal
function log () {
	if [[ $_VERBOSE -eq 1 ]]; then
		if [ -n "$1" ]; then
			IN="$@"
		else
			# This reads a string from stdin and stores it in a variable called IN
			while read LINE; do
				IN+="$LINE\n"
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
		sudo apt-get --yes install "${package}"
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
	#echo $(lsb_release -r | grep -oP "[0-9]+[.][0-9]+")
	lsb_release -r | cut -f2
}

function getPythonPackage () {
	local package="$1"
	local piplist="$(pip list 2>/dev/null)"
	if [[ "$piplist" != *"$package"* ]]; then
		log "Python package ${package} not installed. Installing it now"
		pip install "$package"
	fi
}

# Verify that the required package has been installed
function getPythonPackages () {
	log "Verifying and installing these packages if needed: $@"
	for p in "$@"; do
		getPythonPackage "$p"
	done
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

# Clones a git repo to src dir
# Pushes 2 levels deep
function cloneGitRepo () {
	local srcDir="$1"
	local repoAddr="$2"
	local repoName="${repoAddr##*/}"
	local repoName="${repoName%%.*}"

	pushd "$srcDir"
	if [[ ! -d "$repoName" ]]; then
		sudo git clone "$repoAddr" | log
	else
		log "Source file location already exists at \"$srcDir/$repoName\""
		log "Assuming it's a git repo and trying to pull updates."
		sudo git -C "$repoName" pull
	fi
	sudo chown -R "$USER" "$repoName"
	pushd "$repoName"
}

# Trim whitespace
# Ref: https://stackoverflow.com/a/3352015
trim()
{
    local var="$*"
    # remove leading whitespace characters
    var="${var#"${var%%[![:space:]]*}"}"
    # remove trailing whitespace characters
    var="${var%"${var##*[![:space:]]}"}"
    echo -n "$var"
}

# Join strings. Supports multicharacter delimiters and ignores empty strings.
# Ref: http://stackoverflow.com/questions/1527049/bash-join-elements-of-an-array
function strJoin { perl -e '$s = shift @ARGV; @ARGV = grep { $_ } @ARGV; print join($s, @ARGV);' "$@"; }

# Ref: http://unix.stackexchange.com/a/259254
bytesToHuman() {
	b=${1:-0}; d=''; s=0; S=(Bytes {K,M,G,T,E,P,Y,Z}iB)
	while ((b > 1024)); do
		d="$(printf ".%02d" $((b % 1024 * 100 / 1024)))"
		b=$((b / 1024))
		let s++
	done
	echo "$b$d ${S[$s]}"
}

function wifiGetName () { iwconfig 2>&1 | grep -oP '^[a-zA-Z0-9]+(?=[ ]+IEEE.*)'; }
function wifiGetSsid () { iwconfig 2>&1 | grep -oP '(?<=ESSID:").*(?=")'; }

# Tests if first argument is contained in the latter arguments
# Ref: https://stackoverflow.com/a/8574392/4146779
elementIn () {
	local e match="$1"
	shift
	for e; do [[ "$e" == "$match" ]] && return 0; done
	return 1
}
