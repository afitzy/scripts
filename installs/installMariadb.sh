#!/bin/bash

scriptName="$(basename "$0")"
scriptDir="$( cd "$( dirname "${BASH_SOURCE[0]}" )" && pwd )"
dateStamp=$(date --iso-8601="seconds")

source "${scriptDir}/../utils.sh"


# Ref: https://www.digitalocean.com/community/tutorials/how-to-install-mariadb-on-ubuntu-22-04
function installMariadb ()
{
	# install
	sudo apt-get install --yes mariadb-server

	# Configure, interactive
	sudo mysql_secure_installation

	# Creating an Administrative User that Employs Password Authentication
	# SKIP

	# Test it
	sudo systemctl status mariadb
	sudo mysqladmin version
}

function restoreFromSqlBackup ()
{
	# Ref: https://dba.stackexchange.com/a/285253
	# The solution is to simply add the following two lines to the top of your all-dbs.sql dump file:
	# DROP TABLE IF EXISTS `mysql`.`global_priv`;
	# DROP VIEW IF EXISTS `mysql`.`user`;

	# Ref: https://blog.devart.com/how-to-restore-mysql-database-from-backup.html
	mysql -u root -p < alldatabases.sql
}

function stopAndRemove ()
{
	# Ref: https://dba.stackexchange.com/a/261995
	sudo systemctl stop mysql
	sudo rm -rf /var/lib/mysql/*
	sudo apt-get remove --yes --purge mariadb-server
	sudo apt-get autoremove --yes
}

_VERBOSE=1
if [[ "$(getOsVers)" == "22.04" ]]; then
	installMariadb
else
	echo "Unrecognized OS version. Not installed pre-requisites."
fi
