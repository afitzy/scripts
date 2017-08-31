#!/bin/bash

source utils.sh
source config.sh

scriptName="$(basename "$0")"
cmdSsh="ssh -f -N -4 -c aes256-gcm@openssh.com -L ${fwdPortLocal}:localhost:${fwdPortRemote} -p ${remoteSshPort} \"${remoteSshUser}@${remoteSshAddr}\" -i ${sshprivkey}"

function startSynergy () {
	log "$scriptName: remoteSshAddr=$remoteSshAddr; remoteSshPort=$remoteSshPort; remoteSshUser=$remoteSshUser; fwdPortLocal=$fwdPortLocal; fwdPortRemote=$fwdPortRemote"

	if ! pgrep "$cmdSsh" > /dev/null ; then
		log "$scriptName: SSH: Creating tunnel"
		eval $cmdSsh
	else
		log "$scriptName: SSH: Tunnel already exists."
	fi

	if ! pgrep -x synergyc > /dev/null ; then
		log "$scriptName: Synergy: Starting"
		synergyc localhost:${fwdPortLocal} & &>/dev/null
	else
		log "$scriptName: Synergy: Already running"
	fi
}

function stopSynergy () {
	sudo --user=$username pkill -u $username --newest synergyc
	sudo --user=$username pkill -u $username --newest "$cmdSsh"
}


# NOTE: This requires GNU getopt.  On Mac OS X and FreeBSD, you have to install this separately
PARSED="$(getopt --options vd --long "verbose,debug,enable,disable" -n "$scriptName" -- "$@")"
if [ $? != 0 ] ; then
	log "$scriptName: getopt has complained about wrong arguments to stdout"
	echo "$scriptName: Terminating..." >&2
	exit 1
fi
eval set -- "$PARSED"

_VERBOSE=0
_DEBUG=0
_ENABLE=1
while true; do
  case "$1" in
    -v | --verbose ) _VERBOSE=1; shift ;;
    -d | --debug ) _DEBUG=1; shift ;;
    --enable ) _ENABLE=1; shift ;;
    --disable ) _ENABLE=0; shift ;;
    -- ) shift; break ;;
    * ) break ;;
  esac
done

targetSsid=$ssidAiTorontoPeter
wifiSsid="$(wifiGetSsid)"
if [ "$wifiSsid" == "$targetSsid" ] && [ "$_ENABLE" -eq 1 ]; then
	log "$scriptName: Starting. Wireless network SSID is \"${wifiSsid}\""
	startSynergy
else
	log "$scriptName: Stopping"
	stopSynergy
fi
