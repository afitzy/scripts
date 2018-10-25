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

function installApacheModSecurity() {
  local -c friendlyName="apacheModSecurity"
  sudo apt-get install --yes libapache2-modsecurity modsecurity-crs

  local -c isEnabled=$(sudo apachectl -M 2>/dev/null | grep security)
  if [[ -n "$isEnabled" ]] ; then
    echo "$friendlyName: successfully installed"
  fi

  # Enable mod_security rule engine
  local -c modsecConf="/etc/modsecurity/modsecurity.conf"
  sudo mv /etc/modsecurity/modsecurity.conf-recommended "$modsecConf"
  local -c modsecRuleEngineSetting="on"
  sudo perl -pi -e "s/(?<=SecRuleEngine ).*/$modsecRuleEngineSetting/" "$modsecConf"
  sudo service apache2 restart

  # mod_security comes with core rule set (security rules) at /usr/share/modsecurity-crs
  # For uptodate CRS, download mod_security CRS from GitHub instead

  # remove the default CRS & download latest version of mod_security CRS
  sudo rm -rf /usr/share/modsecurity-crs
  git clone https://github.com/SpiderLabs/owasp-modsecurity-crs.git /usr/share/modsecurity-crs

  # Rename the example setup file
  cd /usr/share/modsecurity-crs
  mv crs-setup.conf.example crs-setup.conf

  # Enable these rules so it will work with Apache
  local -c modsecApacheSecConf="/etc/apache2/mods-enabled/security2.conf"

  local -c modsecApacheSecConfCommentOut="IncludeOptional /usr/share/modsecurity-crs/owasp-crs.load"
  # To-do fix this to comment out just this line
  #sudo perl -pi -e "s/^(\s+$modsecApacheSecConfCommentOut)/#\$1/" "$modsecApacheSecConf"

  local -c modsecApacheSecConfOptComment="# Added by ${scriptName}::${friendlyName} on ${dateStamp}"
  local -c modsecApacheSecConfOpt1='IncludeOptional "/usr/share/modsecurity-crs/*.conf"'

  # TODO Instead of adding all the rules, suggest that rules are added explicitly from the folder. Makes it easier to add/remove them individually.
  local -c modsecApacheSecConfOpt2='IncludeOptional "/usr/share/modsecurity-crs/rules/*.conf"'
  sudo perl -i.bak -pe "\$_ = qq[\n\$_] if \$_ eq qq[</IfModule>\n]" "$modsecApacheSecConf"
  sudo perl -i.bak -pe "\$_ = qq[\t${modsecApacheSecConfOptComment}\n\$_] if \$_ eq qq[</IfModule>\n]" "$modsecApacheSecConf"
  sudo perl -i.bak -pe "\$_ = qq[\t${modsecApacheSecConfOpt1}\n\$_] if \$_ eq qq[</IfModule>\n]" "$modsecApacheSecConf"
  sudo perl -i.bak -pe "\$_ = qq[\t${modsecApacheSecConfOpt2}\n\$_] if \$_ eq qq[</IfModule>\n]" "$modsecApacheSecConf"
  sudo service apache2 restart
}

# References:
# https://blog.rapid7.com/2017/04/09/how-to-configure-modevasive-with-apache-on-ubuntu-linux/
function installApacheModEvasive() {
  local -c friendlyName="apacheModEvasive"
  sudo apt-get install --yes libapache2-mod-evasive

  local -c isEnabled=$(sudo apachectl -M 2>/dev/null | grep evasive)
  if [[ -n "$isEnabled" ]] ; then
    echo "$friendlyName: successfully installed"
  fi

  local -c modevLogDir="/var/log/mod_evasive"
  sudo vim /etc/apache2/mods-enabled/evasive.conf
  sudo mkdir --parents "$modevLogDir"
  sudo chown -R www-data:www-data "$modevLogDir"
  sudo service apache2 restart
}


_VERBOSE=1

if [[ "$(getOsDistro)" == "Debian" ]] && [[ "$(getOsVers)" == "9.5" ]]; then
  installZoneMinderDebian
  installApacheModSecurity
  installApacheModEvasive
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
