#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")

source ../utils.sh

sambaGroup="sambashare"
username="$1"

if [[ "$(getOsVers)" == "16.04" ]]; then
	# Create an OS user
	sudo adduser \
		--no-create-home \
		--disabled-password \
		--disabled-login \
		--shell /usr/sbin/nologin \
		--groups "${sambaGroup}" \
		"$username"

	# Create a samba user
	sudo smbpasswd -a "$username"

	# Restart the samba server
	sudo service smbd restart
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
