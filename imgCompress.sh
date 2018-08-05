#!/bin/bash

# NIX Advance Digital Frame 8 Inch: 1024 x 768 pixels
# Nixplay Seed 8 inch: 1024 x 768 HD
# Nixplay Seed 10 inch: 1024 x 768 HD

scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
source "${scriptDir}/utils.sh"

scriptName="$(basename "$0")"
dateStamp=$(date --iso-8601="seconds")

function verifyContinue () {
	if [[ $_INTERACTIVE -eq 1 ]]; then
		read -p "Do you want to continue? [y/n] " -n 1 -r
		echo
		if [[ ! $REPLY =~ ^[Yy]$ ]] ; then
			[[ "$0" = "$BASH_SOURCE" ]] && exit 1 || return 1 # handle exits from shell or function but don't exit interactive shell
		fi
	fi
}

PARSED="$(getopt --options vdo: --long "verbose,debug,output:" -n "$scriptName" -- "$@")"
if [ $? != 0 ] ; then
	log "getopt has complained about wrong arguments to stdout"
	echo "Terminating..." >&2
	exit 1
fi
eval set -- "$PARSED"

_INTERACTIVE=1
_VERBOSE=0
_DEBUG=0
outputDir=resized
while true; do
	case "$1" in
		-v | --verbose ) _VERBOSE=1; shift ;;
		-d | --debug ) _DEBUG=1; shift ;;
		-o | --output ) outputDir="$2"; shift 2 ;; # Use %s
		-- ) shift; break ;;
		* ) break ;;
	esac
done

# Positional arguments
resolutionStr="${@:$OPTIND:1}"; shift;
pattern="${@:$OPTIND:1}"; shift;

if [ -z "$resolutionStr" ]; then
	echo "ERROR: Missing required argument 1: image resolution string"
	exit -1
fi

if [ -z "$pattern" ]; then
	pattern='*'
	echo "ERROR: Missing required argument 2: file name pattern. Using default pattern: ${pattern}"
fi

if [ -d "$outputDir" ]; then
	echo "WARNING: Output directory \"${outputDir}\" already exists."
	verifyContinue
fi
mkdir "$outputDir" 2>&1 > /dev/null

echo "Output directory = $outputDir"
echo "File name pattern = $pattern"
echo "Resize resolution = $resolutionStr"

path=.
fileList=$(find "$path" -maxdepth 1 -name "$pattern" -exec file {} \; | grep -oP '^.+(?=: \w+ image)')
numFiles=0
IFS=$'\n'
for f in ${fileList}; do
	numFiles=$((numFiles+1))
	outFile="${f##*/}"
	outFull="${outputDir}/${outFile}"
	printf "Resizing #%s: \"%s\" to \"%s\"\n" "$numFiles" "$outFile" "$outFull"

	# http://www.imagemagick.org/Usage/resize/
	convert "$f" \
		-auto-orient \
		-resize "$resolutionStr" \
		"$outFull"
		#-resize 50%
		#-quality 50 \

	# identify format string options:
	# https://www.imagemagick.org/script/escape.php
	srcInfo="$(identify -format '%[width]x%[height] %[size]' "$f")"
	dstInfo="$(identify -format '%[width]x%[height] %[size]' "$outFull")"
	printf "Resized #%s: \"%s\" (%s) to \"%s\" (%s)\n" "$numFiles" "$outFile" "$srcInfo" "$outFull" "$dstInfo"
done
unset IFS
