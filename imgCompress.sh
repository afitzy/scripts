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

# NOTE: This requires GNU getopt.  On Mac OS X and FreeBSD, you have to install this separately
PARSED="$(getopt --options vdm: --long "verbose,debug,debugfile:,ext:,output:" -n ${scriptName} -- "$@")"

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

# Note the quotes around `$PARSED': they are essential!
eval set -- "$PARSED"

_INTERACTIVE=1
_VERBOSE=0
_DEBUG=0
outputDir=resized
while true; do
	case "$1" in
		-v | --verbose ) _VERBOSE=1; shift ;;
		-d | --debug ) _DEBUG=1; shift ;;
		-e | --ext ) ext="$2"; shift 2 ;;
		--output ) outputDir="$2"; shift 2 ;; # Use %s
		-- ) shift; break ;;
		* ) break ;;
	esac
done

# Positional arguments
resolutionStr="${@:$OPTIND:1}"; shift;
pattern="${@:$OPTIND:1}"; shift;

if [ -z "$pattern" ]; then
	echo "ERROR: Missing required argument 1: file name pattern"
	exit -1
fi

if [ -z "$resolutionStr" ]; then
	echo "ERROR: Missing required argument 2: image resolution string"
	exit -1
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
numFiles=0
IFS=$'\n'
for f in $(find ${path} -maxdepth 1 -name "$pattern"); do
	numFiles=$((numFiles+1))
	outFile="${f##*/}"
	outFull="$outputDir/$outFile"

	# http://www.imagemagick.org/Usage/resize/
	convert "$f" \
		-auto-orient \
		-resize "${resolutionStr}" \
		"$outFull"
		#-resize 50%
		#-quality 50 \

	# identify format string options:
	# https://www.imagemagick.org/script/escape.php
	srcInfo="$(identify -format '%[width]x%[height] %[size]' "$f")"
	dstInfo="$(identify -format '%[width]x%[height] %[size]' "$outFull")"
	echo "Resized \"$outFile\" (${srcInfo}) to \"$outFull\" (${dstInfo})"
done
unset IFS
