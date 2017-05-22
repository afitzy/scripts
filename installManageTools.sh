#!/bin/bash

source utils.sh

tempdir=$(mktemp -d)

# Function to cleanup
function cleanup () {
        log "Deleting temp directory: $tempdir"
        rm -rf "$tempdir"
}
trap cleanup EXIT


_VERBOSE=1

function getGanttProject () {
        local url="http://www.ganttproject.biz/dl/2.8.5/lin"
        local filename="ganttproject.deb"
        local filenameAbs="${tempdir}/${filename}"
        
        wget \
                --directory-prefix="$tempdir" \
                --output-document="$filenameAbs" \
                "$url"
                
        #local installFile="$(find -iname "*.deb" -print -quit)"
        sudo dpkg --install "$filenameAbs"  | log
}

if [[ "$(getOsVers)" == "16.04" ]]; then
	getGanttProject 
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
