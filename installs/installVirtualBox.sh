#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")

source "${scriptDir}/../utils.sh"

function removeVirtualBox ()
{
	local -r friendlyName="VirtualBox"
	echo "${friendlyName}: removing previous installation"
	sudo apt-get remove --purge virtualbox*
	sudo apt-get clean
	sudo apt-get autoremove --yes
}

function installVitualBoxFromMultiverse ()
{
	removeVirtualBox
	sudo apt-get install --yes virtualbox virtualbox-ext-pack virtualbox-guest-* virtualbox-qt
}

# The binaries in this repository are all released under the VirtualBox Personal
# Use and Evaluation License (PUEL). By downloading, you agree to the terms and
# conditions of that license.
# Ref: https://www.ubuntuupdates.org/ppa/virtualbox.org_contrib
function installVirtualBoxFromOracle ()
{
	local -r removeOldVersion="$1"
	local -r version="${2:-1}"

	local -r friendlyName="VirtualBox"

	if [[ "$removeOldVersion" -eq 1 ]]; then
		removeVirtualBox
	fi

	echo "${friendlyName}: downloading Oracle key"
	local url='http://download.virtualbox.org/virtualbox/debian/oracle_vbox_2016.asc'
	wget --quiet --output-document=- ${url} | sudo apt-key add -

	echo "${friendlyName}: setting up repository"
	ubuntuRelease=$(lsb_release -cs)
	sudo sh -c "echo 'deb http://download.virtualbox.org/virtualbox/debian ${ubuntuRelease} non-free contrib' > /etc/apt/sources.list.d/virtualbox.org.list"

	echo "${friendlyName}: refreshing multiverse"
	sudo apt-get update

	echo "${friendlyName}: installing"
	sudo apt-get install --yes virtualbox-${version}

	# These conflict with virtualbox-5.2
	# sudo apt-get install --yes virtualbox-guest-* virtualbox-qt
}

function installVirtualBoxFromOracle_v5.2 () {
	local -r removeOldVersion=1
	local -r version=5.2
	installVirtualBoxFromOracle "$removeOldVersion" "$version"
}

function installVirtualBoxFromOracle_v6.0 () {
	local -r removeOldVersion=1
	local -r version=6.0
	installVirtualBoxFromOracle "$removeOldVersion" "$version"
}

# Installs the correct version of the VirtualBox extension pack
# DO NOT use the one from the multiverse, as that's only compatible with the obsolete VirtualBox from the multiverse.
# Ref: https://askubuntu.com/a/759200/271027
function installVirtualBoxExtensionPack () {
	local -r VBOXVERSION=$(VBoxManage --version | sed -r 's/([0-9])\.([0-9])\.([0-9]{1,2}).*/\1.\2.\3/')
	wget -q -N "http://download.virtualbox.org/virtualbox/${VBOXVERSION}/Oracle_VM_VirtualBox_Extension_Pack-${VBOXVERSION}.vbox-extpack"
	sudo VBoxManage extpack install --replace Oracle*.vbox-extpack
	rm Oracle*.vbox-extpack
}

# Installs PHP VirtualBox.
# Requires: virtual box extension pack
# Ref: https://www.ostechnix.com/install-oracle-virtualbox-ubuntu-16-04-headless-server/
function installPhpVirtualBox () {
	sudo apt install apache2 php php-mysql libapache2-mod-php php-soap php-xml

	# Download the matching version of phpvirtualbox
	#wget https://github.com/phpvirtualbox/phpvirtualbox/archive/5.2-1.zip
	# Grab the latest develop, since 6.X isn't officially supported yet
	git clone https://github.com/phpvirtualbox/phpvirtualbox.git

	sudo mv phpvirtualbox/ /var/www/html/phpvirtualbox
	sudo chmod 777 /var/www/html/phpvirtualbox/
	sudo cp /var/www/html/phpvirtualbox/config.php-example /var/www/html/phpvirtualbox/config.php

	# Edit phpVirtualBox config.php file to configure the user, which is likely ${USER}
	# According to https://sourceforge.net/p/phpvirtualbox/discussion/help/thread/0c491caa/#34c2
	# the user must be the one that's actively logged in
	sudo vim /var/www/html/phpvirtualbox/config.php

	# Configure the user
	echo "VBOXWEB_USER=${USER}" | sudo tee -a /etc/default/virtualbox

	# Restart services
	sudo systemctl restart vboxweb-service
	sudo systemctl restart vboxdrv
	sudo systemctl restart apache2

	# Permit incoming HTTP and HTTPS traffic for this profile
	sudo ufw allow in "Apache Full"
}

_VERBOSE=1
if [[ "$(getOsVers)" == "16.04" || "$(getOsVers)" == "18.04" ]]; then
	installVirtualBoxFromOracle_v6.0
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
