#!/bin/bash

# Cleanup
cleanup () {
	echo "Deleting temporary files"
	rm -rf "$tempsrc"
	rm -rf "$tempdest"
	rm -rf "$tempdir"
}
trap cleanup EXIT

# NOTE: This requires GNU getopt.  On Mac OS X and FreeBSD, you have to install this
# separately; see below.
TEMP="$(getopt -o vd --long "verbose,debug,textHeading:,textSubheading:,padding:" -n "${0##*/}" -- "$@")"

if [ $? != 0 ] ; then echo "Terminating..." >&2 ; exit 1 ; fi

# Note the quotes around `$TEMP': they are essential!
eval set -- "$TEMP"

scriptName="$(basename "$0")"
dateStr=$(date --iso-8601="seconds")
_VERBOSE=0
_DEBUG=0
_INSTALL=0
textHeading="Heading"
textSubheading=""
tempdir="$(mktemp -d)"
padding="5 cm"
while true; do
	case "$1" in
		-v | --verbose ) _VERBOSE=1; shift ;;
		-d | --debug ) _DEBUG=1; shift ;;
		-i | --install ) _INSTALL=1; shift ;;
		--textHeading ) textHeading="$2"; shift 2 ;;
		--textSubheading ) textSubheading="$2"; shift 2 ;;
		--padding ) padding="$2"; shift 2 ;;
		-- ) shift; break ;;
		* ) break ;;
	esac
done

# Positional arguments
destPdf="${@:$OPTIND:1}"; shift ;
if [ -z "$destPdf" ] ; then
	destPdf="${scriptName%.sh}_${dateStr}.pdf"
fi

doc="
\documentclass{article}

\begin{document}
\thispagestyle{empty}% empty header/footer

\vspace*{${padding}}
\begin{center}
\bfseries\Huge
${textHeading}
\end{center}
\centerline{${textSubheading}}

\clearpage

\end{document}
"

tempsrc="${tempdir}/doc.tex"
echo "$doc" > "$tempsrc"
pdflatex -interaction batchmode -output-directory "$tempdir" "$tempsrc"
tempdest="${tempdir}/doc.pdf"

echo "Temp directory: $tempdir"
echo "Temp tex source: $tempsrc"
echo "Temp tex dest: $tempdest"

cp "$tempdest" "$destPdf"
okular "$destPdf" &
