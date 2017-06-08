#!/bin/bash

source utils.sh

# NOTE: This requires GNU getopt.  On Mac OS X and FreeBSD, you have to install this
# separately; see below.
PARSED="$(getopt --options vdi: --long "verbose,debug,startIdx:" -n 'pianobar.sh' -- "$@")"

if [ $? != 0 ] ; then
	log "getopt has complained about wrong arguments to stdout"
	echo "Terminating..." >&2
	exit 1
fi

# Note the quotes around `$PARSED': they are essential!
eval set -- "$PARSED"

_VERBOSE=0
_DEBUG=0
_START_IDX=1
while true; do
	case "$1" in
		-v | --verbose ) _VERBOSE=1; shift ;;
		-d | --debug ) _DEBUG=1; shift ;;
		-i | --startIdx ) _START_IDX="$2"; shift 2 ;;
		-- ) shift; break ;;
		* ) break ;;
	esac
done

# Install prereqs for getFreeUsProxies.py
getPythonPackages "enum34" "requests"
proxies=("$(getFreeUsProxies.py --max=1 --port=80 --startIdx=${_START_IDX})")

for proxy in ${proxies[@]}; do
	echo "Trying proxy $proxy"
	proxyEsc=${proxy//\//\\\/}
	# echo "Escaped $proxyEsc"

	# Uncomment control_proxy line if necessary
	perl -pi -e "s/^#(?=control_proxy)//" "${HOME}/.config/pianobar/config"

	# Add a proxy address
	perl -pi -e "s/(?<=control_proxy = ).*/$proxyEsc/" "${HOME}/.config/pianobar/config"

	# Start pianobar
	# if [ "$(pianobar | grep -o "error")" == "error" ] ; then
	# 	echo "epic fail"
	# fi
done
