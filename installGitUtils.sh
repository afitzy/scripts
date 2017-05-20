#!/bin/bash

source utils.sh

_VERBOSE=1

function installMork ()
{
	local binDir="/usr/local/bin"
	local srcDir="/usr/local/src"

	local repoAddr="https://github.com/KevinGoodsell/mork-converter"
	local repoName="${repoAddr##*/}"

	sudo apt-get install python-ply

	cloneGitRepo "$srcDir" "$repoAddr"
	sudo ln -fs "${srcDir}/${repoName}/src/mork" "${binDir}/mork"
}


if [[ "$(getOsVers)" == "16.04" ]]; then
	# For office diffs
	getPackages "docx2txt" "catdoc" "odt2txt" "pdf2txt" "python-excelerator" "xlsx2csv"

	# For Thunderbird diffs
	installMork
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
