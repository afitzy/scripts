#!/bin/bash

scriptName="$(basename "$0")"
dateStamp=$(date --iso-8601="seconds")

# NOTE: This requires GNU getopt.  On Mac OS X and FreeBSD, you have to install this separately
PARSED="$(getopt --options vdm: --long "verbose,debug,debugfile:,ext:,output:" -n ${scriptName} -- "$@")"

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

# Note the quotes around `$PARSED': they are essential!
eval set -- "$PARSED"

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
pattern="${@:$OPTIND:1}"; shift;


if [ -f "$outputDir" ]; then
	echo "WARNING: Output directory \"${outputDir}\" already exists."
	exit 1
fi
mkdir "$outputDir"

path=.
numFiles=0
IFS=$'\n'
for f in $(find ${path} -maxdepth 1 -name "$pattern"); do
	numFiles=$((numFiles+1))
	outFile="${f##*/}"
	outFull="$outputDir/$outFile"

	# http://www.imagemagick.org/Usage/resize/
	convert "$f" \
		-resize 1600x1200\> \
		"$outFull"
		#-resize 50%
		#-quality 50 \

	srcSize="$(du --human-readable "$f" | cut -f 1)"
	dstSize="$(du --human-readable "$outFull" | cut -f 1)"
	echo "Resized $f (${srcSize}) to $outFull (${dstSize})"
done
unset IFS
