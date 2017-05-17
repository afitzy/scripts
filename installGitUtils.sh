#!/bin/bash

source utils.sh

_VERBOSE=1

function installMork ()
{
	local binDir="/usr/local/bin"
	local srcDir="/usr/local/src"

	sudo apt-get install python-ply

	cloneGitRepo "$srcDir" "https://github.com/KevinGoodsell/mork-converter"
	sudo ln -s "${srcDir}/python-mork-converter/src/mork" "${binDir}/mork"
}


if [[ "$(getOsVers)" == "16.04" ]]; then
	# For office diffs
	getPackages "docx2txt" "catdoc" "odt2txt" "pdf2txt" "python-excelerator" "xlsx2csv"

	# For Thunderbird diffs
	installMork
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
