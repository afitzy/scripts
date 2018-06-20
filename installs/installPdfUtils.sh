#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")
tempdir=$(mktemp -d)

source "${scriptDir}/../utils.sh"

# Function to cleanup
function cleanup () {
	log "Deleting temp directory: $tempdir"
	rm -rf "$tempdir"
}
trap cleanup EXIT

function getPdfsandwich () {
	local friendlyName="pdfsandwich"

	echo "${friendlyName}: removing previous installation"
	sudo apt-get remove --yes pdfsandwich

	echo "${friendlyName}: downloading $urlFilename"
	local url="http://sourceforge.net/projects/pdfsandwich/files/pdfsandwich_0.1.6_amd64.deb/download"
	local urlFilename=$(echo "$url" | rev | cut --delimiter='/' --fields=2 | rev)
	local filenameAbs="${tempdir}/${urlFilename}"
	wget --output-document="$filenameAbs" "$url" 2>&1 | while read -r line; do log ; done

	echo "${friendlyName}: installing"
	sudo dpkg --install "$filenameAbs" 2>&1 | log
	echo "${friendlyName}: done"
}

if [[ "$(getOsVers)" == "16.04" ]]; then
	# pdfsandwich generates "sandwich" OCR pdf files
	# http://www.tobias-elze.de/pdfsandwich/
	getPdfsandwich

	# OCR tool and language packs
	sudo apt-get install --yes tesseract-ocr tesseract-ocr-eng tesseract-ocr-chi-sim tesseract-ocr-chi-tra

	# unpaper is a post-processing tool for scanned sheets of paper.
	# Purpose is to make scanned book pages better readable on screen after conversion to PDF
	sudo apt-get install --yes unpaper
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
