#!/bin/bash

# This script can be used to easily edit an existing web project:
# - change project name (TODO)
# - change document root (TODO)
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

########################
### Get project name ###
########################

read -p 'Enter existing project name: ' project_name
while [[ ! -d "$projects_directory/$project_name" || -z $project_name ]]; do 
	echo "Project '$project_name' does not exists."
	read -p 'Enter existing project name: ' project_name
done

#######################
### Get edit action ###
#######################

echo "Project '$project_name' selected."
echo "Enter number to select edit option:"
echo "[1] Rename project"
echo "[2] Change document root"

read -p ':' edit_option
while [[ ! $edit_option =~ ^[1-2]$ ]]; do
	echo "Unkown action. Enter a number listed above."
	read -p ':' edit_option
done

####################
### Edit project ###
####################

case $edit_option in
    1)
		while [[ ! $project_name_new =~ ^[a-zA-Z0-9_-]+$ || -d /var/www/$project_name_new ]]; do 
			read -p 'Enter project name: ' project_name_new
			if [[ ! $project_name_new =~ ^[a-zA-Z0-9_-]+$ ]]; then 
				echo "You have to enter a valid project name (allowed: [a-Z][0-9][_][-])."
			elif [[ -d /var/www/$project_name_new ]]; then
				echo "Project name allready in use, please enter another."
			fi
		done
        echo "Project name was changed to '$project_name_new'."
        ;;
    2)
		read -p "Enter new document root: $projects_directory/$project_name/" project_name_new
        echo "Document root was changed to '$projects_directory/$project_name/$project_name_new'."
		;;
	*)
		echo "Selected option not implemented yet."
		;;
esac