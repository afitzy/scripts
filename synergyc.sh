#!/bin/bash

source utils.sh
source config.sh

if [[ "$(getOsVers)" == "16.04" ]]; then
	getPackages "synergy"
else
	log "Unrecognized OS version. Not installed pre-requisites."
fi

ssh -f -N -4 -C -c aes256-gcm@openssh.com -L ${fwdPortLocal}:localhost:${fwdPortRemote} -p ${remoteSshPort} "${remoteSshUser}@${remoteSshAddr}"
