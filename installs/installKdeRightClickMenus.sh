#!/bin/bash

source utils.sh

_VERBOSE=1

if [[ "$(getOsVers)" == "16.04" ]]; then
	sudo ln -s /usr/share/kde4/servicetypes/konqpopupmenuplugin.desktop /usr/share/kservices5/ServiceMenus/
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
