#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")

source "${scriptDir}/../utils.sh"

# Relevant install steps copied from:
# Not very relevant to Debian 9:
#   https://zoneminder.readthedocs.io/en/stable/installationguide/debian.html#easy-way-debian-jessie
# Helpful for Debian 9:
#   https://www.tecmint.com/install-zoneminder-video-surveillance-software-on-debian-9/
#   https://wiki.zoneminder.com/Debian_9_64-bit_with_Zoneminder_1.30.4_the_Easy_Way
function installZoneMinderDebian() {
  echo "Step 3: Install Apache and MySQL"
  # These are not dependencies for the package as they could be installed elsewhere.
  sudo apt-get install --yes zoneminder apache2 mysql-server php php-mysql libapache2-mod-php7.0 php7.0-gd

  echo "Step 5: Install ZoneMinder"
  sudo apt-get update
  sudo apt-get install --yes zoneminder

  echo "Step 6: Read the Readme"
  # The rest of the install process is covered in the README.Debian, so feel free to have a read.
  local -r readme='/usr/share/doc/zoneminder/README.Debian'
  gunzip "${readme}.gz"
  echo "REMINDER: You should read the doc at \"${readme}\""

  echo "Step 7: Setup Database"
  # Install the zm database and setup the user account. Refer to Hints in Ubuntu install should you choose to change default database user and password.
  cat /usr/share/zoneminder/db/zm_create.sql | sudo mysql --defaults-file=/etc/mysql/debian.cnf
  echo 'grant lock tables,alter,create,select,insert,update,delete,index on zm.* to 'zmuser'@localhost identified by "zmpass";'    | sudo mysql --defaults-file=/etc/mysql/debian.cnf mysql

  echo "Step 8: zm.conf Permissions"
  # Adjust permissions to the zm.conf file to allow web account to access it.
  sudo chmod 740 /etc/zm/zm.conf
  sudo chown root:www-data /etc/zm/zm.conf
  sudo chown -R www-data:www-data /usr/share/zoneminder/

  echo "Step 9: Setup ZoneMinder service"
  sudo systemctl enable zoneminder.service

  echo "Step 10: Configure Apache"
  # The following commands will setup the default /zm virtual directory and configure required apache modules.
  sudo a2enconf zoneminder
  sudo a2enmod cgi
  sudo a2enmod rewrite

  echo "Step 11: Edit Timezone in PHP"
  # Search for [Date] (Ctrl + w then type Date and press Enter) and change date.timezone for your time zone. Don’t forget to remove the ; from in front of date.timezone
  #nano /etc/php/7.0/cli/php.ini
  # Might also be here: /etc/php/7.0/apache2/php.ini’
  # Canada/Eastern
  # sed -i "s/;date.timezone =/date.timezone = $(sed 's/\//\\\//' /etc/timezone)/g" /etc/php/7.0/apache2/php.ini

  echo "Step 12: Start ZoneMinder"
  # Reload Apache to enable your changes and then start ZoneMinder.
  sudo systemctl reload apache2
  sudo service apache2 restart
  # sudo systemctl start zoneminder
  sudo systemctl start zoneminder.service

  echo "Confirming that Zoneminder is running"
  sudo systemctl status zoneminder.service

}


_VERBOSE=1

if [[ "$(getOsDistro)" == "Debian" ]] && [[ "$(getOsVers)" == "9.5" ]]; then
  installZoneMinderDebian
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
