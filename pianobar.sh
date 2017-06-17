#!/bin/bash

source utils.sh

scriptName="$(basename "$0")"

function monitorForError () {
	while IFS= read -r line; do
		if [[ $line == *"Network error:"* ]]; then
			echo 1
			return
		fi
	done

	echo 0
	return
}

# Function to cleanup
function cleanup () {
	log "Killing descendant processes"
	pkill -P $$
	killall pianobar 2>&1 > /dev/null
}


# NOTE: This requires GNU getopt.  On Mac OS X and FreeBSD, you have to install this separately
PARSED="$(getopt --options vdi: --long "verbose,debug,install,startIdx:" -n "$scriptName" -- "$@")"
if [ $? != 0 ] ; then
	log "getopt has complained about wrong arguments to stdout"
	echo "Terminating..." >&2
	exit 1
fi
eval set -- "$PARSED"

_VERBOSE=0
_DEBUG=0
_INSTALL=0
_START_IDX=1
while true; do
	case "$1" in
		-v | --verbose ) _VERBOSE=1; shift ;;
		-d | --debug ) _DEBUG=1; shift ;;
		--install ) _INSTALL=1; shift ;;
		-i | --startIdx ) _START_IDX="$2"; shift 2 ;;
		-- ) shift; break ;;
		* ) break ;;
	esac
done

trap cleanup EXIT

if [[ $_INSTALL -eq 1 ]]; then
	# Prereqs for getFreeUsProxies.py
	getPackages "python-pip"
	getPythonPackages "enum34" "requests" "beautifulsoup4"
	exit
fi

proxies=("$(getFreeUsProxies.py --max=20 --port=80 --startIdx=${_START_IDX})")
idx=$(($_START_IDX - 1))
for proxy in ${proxies[@]}; do
	idx=$((idx + 1))
	echo "Trying proxy $idx: $proxy"

	# Uncomment control_proxy line if necessary
	perl -pi -e "s/^#(?=control_proxy)//" "${HOME}/.config/pianobar/config"

	# Add a proxy address
	proxyEsc=${proxy//\//\\\/}
	perl -pi -e "s/(?<=control_proxy = ).*/$proxyEsc/" "${HOME}/.config/pianobar/config"

	# Start pianobar
	hadError=$(stdbuf -oL pianobar 2>&1 | tee >(cat - >/dev/tty) | monitorForError)
	pianobarExitCode=${PIPESTATUS[0]}

	if [[ $hadError == 0 ]] && [[ $pianobarExitCode == 0 ]]; then
		exit
	fi
done
