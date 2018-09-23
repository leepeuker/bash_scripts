#!/bin/bash

# This script can be used to easily remove an existing web project:
# - removes project directory and all its content
# - removes and disables V-Host
# - removes local url entry from /etc/hosts
#
# Requirements: 
# - Apache2

#####################
### Configuration ###
#####################

projects_directory="/var/www"
apache_conf_directory="/etc/apache2/sites-available"

########################
### Get project name ###
########################

read -p 'Enter existing project name: ' project_name
while [[ ! -d "$projects_directory/$project_name" || -z $project_name ]]; do 
	echo "Project '$project_name' does not exists."
	read -p 'Enter existing project name: ' project_name
done

######################
### Remove project ###
######################

rm -r "$projects_directory/$project_name"
rm "/$apache_conf_directory/$project_name.conf"
sed -i "/127.0.0.1 $project_name.local$/d" /etc/hosts

# Reload Apache
a2dissite "$project_name.conf"
systemctl restart apache2

##################
### End script ###
##################

echo "Project '$project_name' removed."
