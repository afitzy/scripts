#!/bin/bash

# Function to conditionally print to terminal
function log () {
	if [[ $_VERBOSE -eq 1 ]]; then
		if [ -n "$1" ]; then
			IN="$1"
			echo -e "$IN"
		else
			# This reads a string from stdin and stores it in a variable called IN
			while read INPUT; do
			  echo "$INPUT"
			done
		fi
	fi
	unset IN
}

function echoerr() { echo "$@" 1>&2; }

function exitIfFileExists () {
	if [ -f $1 ]; then
		echoerr "ERROR: File exists at \"$1\"! Exiting without writing PDF."
		exit
	fi
}

# Function to cleanup
function cleanup () {
	log "Deleting temp directory: $tempdir"
	rm -rf "$tempdir"
}

# NOTE: This requires GNU getopt.  On Mac OS X and FreeBSD, you have to install this separately
TEMP="$(getopt -o vdm: --long "verbose,debug,debugfile:,path:,ext:,output:" -n 'scanImgCrop' -- "$@")"

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

# Note the quotes around `$TEMP': they are essential!
eval set -- "$TEMP"

_VERBOSE=0
_DEBUG=0
_DEBUGFILE=
path=.
ext=jpeg
output="$(date +%FT%T)%s.pdf"
while true; do
  case "$1" in
    -v | --verbose ) _VERBOSE=1; shift ;;
    -d | --debug ) _DEBUG=1; shift ;;
	 --debugfile ) _DEBUGFILE="$2"; shift 2 ;;
	 --path ) path="$2"; shift 2 ;;
	 -e | --ext ) ext="$2"; shift 2 ;;
	 --output ) output="$2"; shift 2 ;; # Use %s
    -- ) shift; break ;;
    * ) break ;;
  esac
done

tempdir=$(mktemp -d)
trap cleanup EXIT
log "Temp directory: $tempdir"

numFiles=0
IFS=$'\n'
for f in $(find ${path} -name "*.${ext}"); do
	numFiles=$((numFiles+1))
	#local filePath="${f%/*}"
	outFile="${f##*/}"
	outFull="$tempdir/$outFile"
	log "Cropping $f to $tempdir"
	convert "$f" -crop 2480x3300+0+0 "$outFull" | log
done
unset IFS

if [ $numFiles -gt 0 ]; then
	pdfHq="$(printf $output "")"
	pdfCompressed="$(printf $output "_compressed")"

	log "Converting ${numFiles} scans to a single PDF as ${pdfHq}"
	exitIfFileExists "${pdfHq}"
	convert "${tempdir}/*.${ext}" "$pdfHq" 2>&1 | log

	log "Compressing PDF to ${pdfCompressed}"
	exitIfFileExists "${pdfCompressed}"
	pdfCompressAvg="gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook -dNOPAUSE -dQUIET -dBATCH -sOutputFile=${pdfCompressed}"
	${pdfCompressAvg} "$pdfHq" 2>&1 | log
else
	log "No files to convert. PDF not created."
fi
