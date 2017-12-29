#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")

source "${scriptDir}/../utils.sh"

function installTranslateRepo ()
{
	local repoAddr="https://github.com/soimort/translate-shell.git"
	local instPrefix="$_DIR_PREFIX"

	sudo apt-get install -y gawk

	cloneGitRepo "$_DIR_SRC" "$repoAddr"
	sudo make install PREFIX="$instPrefix"
	popd
	popd
}


if [[ "$(getOsVers)" == "16.04" ]]; then
	#getPackage translate-shell
	installTranslateRepo
else
	echo "Unrecognized OS version. Not installing."
fi
