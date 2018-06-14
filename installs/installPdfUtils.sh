#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")

source "${scriptDir}/../utils.sh"

# Function to cleanup
function cleanup () {
	log "Deleting temp directory: $tempdir"
	rm -rf "$tempdir"
}
trap cleanup EXIT

_VERBOSE=1

if [[ "$(getOsVers)" == "16.04" ]]; then
	# pdfsandwich generates "sandwich" OCR pdf files
	# http://www.tobias-elze.de/pdfsandwich/
	sudo apt-get install --yes pdfsandwich

	# OCR tool and language packs
	sudo apt-get install --yes tesseract-ocr tesseract-ocr-eng tesseract-ocr-chi-sim tesseract-ocr-chi-tra

	# unpaper is a post-processing tool for scanned sheets of paper.
	# Purpose is to make scanned book pages better readable on screen after conversion to PDF
	sudo apt-get install --yes unpaper
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
