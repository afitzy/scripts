#!/bin/bash

scriptName="$(basename "$0")"

scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"

dateStamp=$(date --iso-8601="seconds")

source "${scriptDir}/../utils.sh"

_VERBOSE=1

function installJava () {

local -r friendlyName="OpenJDK Java 25"
local -r packageName="openjdk-25-jre"

echo "${friendlyName}: installing"
sudo apt-get update
sudo apt-get install --yes "$packageName"

local javaBin
javaBin="$(dpkg -L openjdk-25-jre-headless | grep '/bin/java$' | head -n 1)"

if [[ -z "$javaBin" || ! -x "$javaBin" ]]; then

echo "${friendlyName}: unable to locate installed Java executable."
return 1

fi

echo "${friendlyName}: setting Java 25 as default"
sudo update-alternatives --set java "$javaBin"

local javaVersion
javaVersion="$(java -XshowSettings:properties -version 2>&1 | awk -F '= ' '/java.specification.version =/ {print $2; exit}')"

if [[ "$javaVersion" != "25" ]]; then

echo "${friendlyName}: installation verification failed. Expected Java 25, found Java ${javaVersion:-unknown}."
return 1

fi

echo "${friendlyName}: installed successfully"
java -version

}

if [[ "$(getOsVers)" == "26.04" ]]; then

installJava

else

echo "Unrecognized OS version. Not installed pre-requisites."

fi
