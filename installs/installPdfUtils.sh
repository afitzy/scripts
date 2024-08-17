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

	echo "${friendlyName}: installing prerequisites"
	sudo apt-get install --yes exactimage

	local -r url="https://sourceforge.net/projects/pdfsandwich/files/pdfsandwich%200.1.7/pdfsandwich_0.1.7_amd64.deb/download"
	local -r urlFilename=$(echo "$url" | rev | cut --delimiter='/' --fields=2 | rev)
	local -r filenameAbs="${tempdir}/${urlFilename}"
	echo "${friendlyName}: downloading $urlFilename"
	wget --output-document="$filenameAbs" "$url" 2>&1 | while read -r line; do log ; done

	echo "${friendlyName}: installing"
	sudo dpkg --install "$filenameAbs" 2>&1 | log
	echo "${friendlyName}: done"
}

_VERBOSE=1

if [[ "$(getOsVers)" == "16.04" || "$(getOsVers)" == "18.04" || "$(getOsVers)" == "20.04" || "$(getOsVers)" == "22.04" || "$(getOsVers)" == "24.04" ]]; then
	# OCR tool and language packs
	sudo apt-get install --yes \
		tesseract-ocr \
		tesseract-ocr-chi-sim `#Chinese` \
		tesseract-ocr-chi-tra `#Chinese - Traditional` \
		tesseract-ocr-eng `#english` \
		tesseract-ocr-grc `#Greek, Ancient (to 1453)` \
		tesseract-ocr-lat `#Latin` \
		tesseract-ocr-heb `#Hebrew` \
		tesseract-ocr-ara `#Arabic` \
		tesseract-ocr-deu `#German` \
		tesseract-ocr-fra `#French`

	# unpaper is a post-processing tool for scanned sheets of paper.
	# Purpose is to make scanned book pages better readable on screen after conversion to PDF
	sudo apt-get install --yes unpaper

	# pstoedit - a tool converting PostScript and PDF files into various vector graphic formats
	sudo apt-get install --yes pstoedit

	# Converts XPS (remember Microsoft XPS writer?) to PDF
	sudo apt-get install --yes libgxps-utils

	# HTML to PDF
	sudo apt-get install --yes wkhtmltopdf

	# pdfsandwich generates "sandwich" OCR pdf files
	# Depends on tesseract, which is installed above
	# http://www.tobias-elze.de/pdfsandwich/
	getPdfsandwich
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
