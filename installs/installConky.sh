#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")

source "${scriptDir}/../utils.sh"

# Notes:
# You will also need to install several custom fonts:
# 1) copy into "/usr/local/share/fonts"
# 2) rebuild font cache: fc-cache -f -v

_VERBOSE=1

if [[ "$(getOsVers)" == "16.04" ]]; then
        getPackages "conky" "conky-all" "lua5.1" "hddtemp" "smartmontools" "thermald" "lm-sensors"
else
        log "Unrecognized OS version. Not installed pre-requisites."
fi

conky -c ~/.conky/.conkyDateTime &
conky -c ~/.conky/.conkySysStats &
conky -c ~/.conky/.conkyFortune &
