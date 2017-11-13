#!/bin/bash

source ../utils.sh

if [[ "$(getOsVers)" == "16.04" ]]; then
	getPackage translate-shell
else
	echo "Unrecognized OS version. Not installing."
fi
