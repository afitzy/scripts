#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")

source "${scriptDir}/../utils.sh"

_VERBOSE=1

function installMork ()
{
	local repoAddr="https://github.com/KevinGoodsell/mork-converter"
	local repoName="${repoAddr##*/}"
	local repoName="${repoName%%.*}"


	sudo apt-get install python-ply

	cloneGitRepo "$_DIR_SRC" "$repoAddr"
	sudo ln -fs "${_DIR_SRC}/${repoName}/src/mork" "${_DIR_BIN}/mork"
	popd
	popd
}

function installHub ()
{
	local instPrefix="$_DIR_PREFIX"
	local repoAddr="https://github.com/github/hub.git"

	if [[ "$(getOsVers)" == "16.04" ]]; then
		# Hub needs Go v1.8 or higher
		sudo add-apt-repository -y ppa:longsleep/golang-backports
		sudo apt-get update

		# To-do: Only remove GO if version is too old
		sudo apt-get remove golang-go -y
	fi

	# Install prereqs
	sudo apt-get install --yes golang-go ruby ruby-dev

	# Install ruby gems
	sudo gem install bundler

	cloneGitRepo "$_DIR_SRC" "$repoAddr"
	git checkout 2d345171cddbf61422f19bb8123d57841b6156f6
	sudo make install prefix="$instPrefix"
	popd
	popd
}

function installKdeDolphinPlugin ()
{
	# Warning: This tries to connect to the network frequently
	# Ref: http://aeciosantos.com/2012/10/06/using-dolphinkde-to-manage-git-repositories-or-other-vcs/
	sudo apt-get install --yes kdesdk-dolphin-plugins
	sudo apt-get install --yes dolphin-plugins
	echo "You have to manually configure dolphin to use the git plugin"
}


if [[ "$(getOsVers)" == "16.04" || "$(getOsVers)" == "18.04" || "$(getOsVers)" == "20.04" ]]; then
	# For office diffs
	sudo apt-get install --yes docx2txt catdoc odt2txt python-excelerator xlsx2csv antiword
	sudo apt-get install --yes python-pdfminer # pdf2txt

	# For image diffs
	sudo apt-get install --yes exif

	# For Thunderbird diffs
	installMork

	# For spreadsheet (ods) diffs
	sudo apt-get install --yes gnumeric

	# Hub tools (works best when aliased to git in bash profile)
	installHub

	# KDE Dolphin plugins
	#installKdeDolphinPlugin
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
