#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")

source "${scriptDir}/utils.sh"

function echoerr() { echo "$@" 1>&2; }

function exitIfFileExists () {
	if [[ $_FORCE -eq 0 && -f $1 ]]; then
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
TEMP="$(getopt -o dfv --long "debug,debugfile:,force,verbose,,path:,output:" -n 'scanImgCrop' -- "$@")"

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

# Note the quotes around `$TEMP': they are essential!
eval set -- "$TEMP"

_VERBOSE=0
_DEBUG=0
_DEBUGFILE=
_FORCE=0
path=.
compress=1
output="$(date +%FT%T)%s.pdf"
while true; do
	case "$1" in
		-v | --verbose ) _VERBOSE=1; shift ;;
		-d | --debug ) _DEBUG=1; shift ;;
		--nocompress ) compress=0; shift ;;
		--debugfile ) _DEBUGFILE="$2"; shift 2 ;;
		--force ) _FORCE=1; shift ;;
		--path ) path="$2"; shift 2 ;;
		--output ) output="$2"; shift 2 ;; # Use %s
		-- ) shift; break ;;
		* ) break ;;
	esac
done

# Positional arguments
resolutionStr="${@:$OPTIND:1}"; shift;
pattern="${@:$OPTIND:1}"; shift;

if [ -z "$resolutionStr" ]; then
	echo "ERROR: Missing required argument 1: image resolution string (width X height)"
	exit -1
fi

if [ -z "$pattern" ]; then
	pattern='*'
	echo "ERROR: Missing required argument 2: file name pattern. Using default pattern: ${pattern}"
fi

tempdir=$(mktemp -d)
trap cleanup EXIT
log "Temp directory: $tempdir"

echo "Output = $output"
echo "File name pattern = $pattern"
echo "Resize resolution = $resolutionStr"

maxWidth=$(echo $resolutionStr | cut -d 'x' -f 1)
maxHeight=$(echo $resolutionStr | cut -d 'x' -f 2)

allFiles=$(find "$path" -maxdepth 1 -name "$pattern" -type f | sort)
numFiles=0
IFS=$'\n'
for f in ${allFiles}; do
	numFiles=$((numFiles+1))

	outFile="${f##*/}"
	outFull="$tempdir/$outFile"

	width="$(convert "$f" -format "%w" info:)"
	height="$(convert "$f" -format "%h" info:)"

	xoff="$(convert xc: -format "%[fx:${width}*0/100]" info:)"
	yoff="$(convert xc: -format "%[fx:${height}*0/100]" info:)"
	ww="$(convert xc: -format "%[fx:${width}*${maxWidth}/100]" info:)"
	hh="$(convert xc: -format "%[fx:${height}*${maxHeight}/100]" info:)"

	log "Cropping $f \"${width}x${height}\" to $outFull \"${ww}x${hh}+${xoff}+${yoff}\""
	convert "$f" -crop ${ww}x${hh}+${xoff}+${yoff} "$outFull" | log
done
unset IFS

if [ $numFiles -gt 0 ]; then
	pdfHq=$(printf $output "")
	pdfCompressed=$(printf $output "_compressed")

	log "Converting ${numFiles} scans to a single PDF as ${pdfHq}"
	exitIfFileExists "${pdfHq}"

	# Convert to PDF, using repage to remove any X or Y offset
	# Ref: http://www.imagemagick.org/discourse-server/viewtopic.php?p=134535&sid=0b4da03b7d8d50411e0667a99dd8bc4a#p134535
	convert "${tempdir}/*" +repage "$pdfHq" 2>&1 | log

	if [ $compress -eq 1 ]; then
		log "Compressing PDF to ${pdfCompressed}"
		exitIfFileExists "${pdfCompressed}"
		pdfCompressAvg="gs -sDEVICE=pdfwrite -dCompatibilityLevel=1.4 -dPDFSETTINGS=/ebook -dNOPAUSE -dQUIET -dBATCH -sOutputFile=${pdfCompressed}"
		${pdfCompressAvg} "$pdfHq" 2>&1 | log

		srcSize="$(du --human-readable "$pdfHq" 2>/dev/null | cut -f1)"
		dstSize="$(du --human-readable "$pdfCompressed" 2>/dev/null | cut -f1)"
		log "Compressed \"${pdfHq}\" (${srcSize}) to \"${pdfCompressed}\" (${dstSize})"
	fi
else
	log "No files to convert. PDF not created."
fi
