#!/bin/bash

source utils.sh

_VERBOSE=1

function installMork ()
{
	local binDir="/usr/local/bin"
	local srcDir="/usr/local/src"
	cloneGitRepo "$srcDir" "https://github.com/KevinGoodsell/mork-converter"
	sudo ln -s "${srcDir}/python-mork-converter/src/mork" "${binDir}/mork"
}


if [[ "$(getOsVers)" == "16.04" ]]; then
	getPackages "docx2txt" "catdoc" "odt2txt" "pdf2txt" "python-excelerator" "xlsx2csv"
	installMork
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
