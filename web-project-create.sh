#!/bin/bash

# This script can be used to easily create a new web project:
# - creates project directory (with the submitted document root directory)
# - creates index.php (displaying information about the selected php version)
# - creates and enables V-Host (with selected PHP version)
# - adds local url entry to /etc/hosts
#
# Requirements: 
# - Apache2
# - PHP FPM and FastCGI [https://tecadmin.net/install-multiple-php-version-apache-ubuntu/]

#####################
### Configuration ###
#####################

php_versions=("7.2" "7.1" "5.6")
projects_directory="/var/www"
apache_conf_directory="/etc/apache2/sites-available"

##################################
### Check for root permissions ###
##################################

if [[ $(id -u) -ne 0 ]]; then 
	echo "Please run as root."
	exit
fi

###############################
### Get project information ###
###############################

# Get the project name
while [[ ! $project_name =~ ^[a-zA-Z0-9_-]+$ || -d /var/www/$project_name ]]; do 
	read -p 'Enter project name: ' project_name
	if [[ ! $project_name =~ ^[a-zA-Z0-9_-]+$ ]]; then 
		echo "You have to enter a valid project name (allowed: [a-Z][0-9][_][-])."
	elif [[ -d /var/www/$project_name ]]; then
		echo "Project name allready in use, please enter another."
	fi
done

# Get document root
project_root="$projects_directory/$project_name"
read -rp "Enter document root: $project_root/" project_document_root_directory
project_document_root="$projects_directory/$project_name/$project_document_root_directory"
project_document_root=$project_document_root | sed 's,/$,,g'

# Get the php version
printf -v php_version_string "%s, " "${php_versions[@]}"
php_version_string=${php_version_string%??}
match=0
php_version=""
while [[ -z $php_version || $match -eq 0 ]]; do 
	read -p "Enter php version ($php_version_string): " php_version
	for avaiable_version in ${php_versions[@]}; do
	    if [[ $avaiable_version = $php_version ]]; then
		match=1
		break
	    fi
	done
	if [[ -z $php_version ]]; then 
		echo "You have to enter a php version."
	elif [[ $match -eq 0 ]]; then
		echo "You entered an invalid php version."
	fi
done

##########################
### Create the project ###
##########################

# Create document root
mkdir -p $project_document_root
printf "<?php phpinfo();" > "$project_document_root/index.php"
chown -R $SUDO_USER:$SUDO_USER $project_root
chmod -R 755 $project_root

# Create V-Host
printf "
<VirtualHost *:80>
	DocumentRoot $project_document_root
	ServerName $project_name.local

	<Directory $project_document_root>
		Options -Indexes +FollowSymLinks +MultiViews
		AllowOverride All
		Require all granted
	</Directory>

	<FilesMatch \.php$>
		SetHandler \"proxy:unix:/var/run/php/php$php_version-fpm.sock|fcgi://localhost/\"
	</FilesMatch>

	ErrorLog \${APACHE_LOG_DIR}/error.log
	CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
" > "$apache_conf_directory/$project_name.conf"

# Reload Apache
a2ensite "$project_name.conf" >/dev/null
systemctl reload apache2

# Set local url
printf "127.0.0.1 $project_name.local\n" >> /etc/hosts

##################
### End script ###
##################

echo "Project created!"
echo "##############################################"
echo "# Project name:      $project_name"
echo "# Project directory: $project_root"
echo "# Document root:     $project_document_root"
echo "# PHP version:       $php_version"
echo "# URL:               $project_name.local"
echo "##############################################"