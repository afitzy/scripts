#!/bin/bash

source utils.sh

_VERBOSE=1

function installMork ()
{
	local binDir="/usr/local/bin"
	local srcDir="/usr/local/src"

	local repoAddr="https://github.com/KevinGoodsell/mork-converter"
	local repoName="${repoAddr##*/}"
	local repoName="${repoName%%.*}"


	sudo apt-get install python-ply

	cloneGitRepo "$srcDir" "$repoAddr"
	sudo ln -fs "${srcDir}/${repoName}/src/mork" "${binDir}/mork"
	popd
	popd
}

function installHub ()
{
	local instPrefix="/usr/local/"
	local repoAddr="https://github.com/github/hub.git"

	# Install prereqs
	getPackages "golang-go" "ruby" "ruby-dev"

	# Install ruby gems
	sudo gem install bundler

	cloneGitRepo "$srcDir" "$repoAddr"
	make install prefix="$instPrefix"
	popd
	popd
}

function installKdeDolphinPlugin ()
{
	# Warning: This tries to connect to the network frequently
	# Ref: http://aeciosantos.com/2012/10/06/using-dolphinkde-to-manage-git-repositories-or-other-vcs/
	getPackages "kdesdk-dolphin-plugins"
	getPackages "dolphin-plugins"
	echo "You have to manually configure dolphin to use the git plugin"
}


if [[ "$(getOsVers)" == "16.04" ]]; then
	# For office diffs
	getPackages "docx2txt" "catdoc" "odt2txt" "pdf2txt" "python-excelerator" "xlsx2csv" "antiword"

	# For Thunderbird diffs
	installMork

	# Hub tools (works best when aliased to git in bash profile)
	installHub

	# KDE Dolphin plugins
	#installKdeDolphinPlugin
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
