#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")

source "${scriptDir}/../utils.sh"

tempdir=$(mktemp -d)

# Function to cleanup
function cleanup () {
	log "Deleting temp directory: $tempdir"
	rm -rf "$tempdir"
}
trap cleanup EXIT


_VERBOSE=1

function getPlantUml () {
	# Uninstall existing version
	sudo apt-get remove --yes plantuml

	local binDir="/usr/local/bin"
	local srcDir="/usr/local/src"

	local url="http://sourceforge.net/projects/plantuml/files/plantuml.jar/download"
	local filename="plantuml.jar"
	local filenameAbs="${tempdir}/${filename}"

	wget \
		--directory-prefix="$tempdir" \
		--output-document="$filenameAbs" \
		"$url"

	local srcSubdir="${srcDir}/plantuml"
	sudo mkdir "$srcSubdir"
	sudo mv -f "$filenameAbs" "$srcSubdir"

	local srcBin="${srcSubdir}/${filename}"
	sudo chmod 755 "$srcBin"

	local binBin="${binDir}/plantuml"

	if [[ -f "$binBin" ]]; then
		log "Plantuml binary file already exists at \"$binBin\". Overwriting it."
	fi

sudo tee "$binBin" > /dev/null <<EOL
#!/bin/bash
# Written on ${dateStamp}
java -jar "${srcBin}" "\$@"
EOL

	sudo chmod 755 "$binBin"
}

if [[ "$(getOsVers)" == "16.04" || "$(getOsVers)" == "18.04" || "$(getOsVers)" == "20.04" || "$(getOsVers)" == "22.04" || "$(getOsVers)" == "24.04" ]]; then
	getPlantUml
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
