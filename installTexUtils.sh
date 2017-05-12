#!/bin/bash

source utils.sh

_VERBOSE=1

# Recommended IDE: Texmaker
# Recommended TeX distribution: TeX Live

if [[ "$(getOsVers)" == "16.04" ]]; then
	getPackages "texmaker" "texlive" "texlive-generic-extra" "biber"
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
