#!/bin/bash

#######################################
# Bash script to install a Redmine Project Management Tool in ubuntu
# Author: Subhash (serverkaka.com)

# Check if running as root
if [ "$(id -u)" != "0" ]; then
   echo "This script must be run as root" 1>&2
   exit 1
fi

# Check port 80 is Free or Not
netstat -ln | grep ":80 " 2>&1 > /dev/null
if [ $? -eq 1 ]; then
     echo go ahead
else
     echo Port 80 is allready used
     exit 1
fi

# Ask value for mysql root password 
read -p 'db_root_password [secretpasswd]: ' db_root_password
echo

# Update System
apt-get update

# Install Apache and mod-passenger
apt-get install apache2 libapache2-mod-passenger -y

# Install MySQL database server
export DEBIAN_FRONTEND="noninteractive"
debconf-set-selections <<< "mysql-server mysql-server/root_password password $db_root_password"
debconf-set-selections <<< "mysql-server mysql-server/root_password_again password $db_root_password"
apt-get install mysql-server mysql-client -y
unset DEBIAN_FRONTEND

# Installing and configuring the Ubuntu Redmine package
apt-get install redmine redmine-mysql -y

# Install bundler gem
gem update
gem install bundler

# Configuring Apache
cd /etc/apache2/mods-available/ 
rm passenger.conf
wget https://s3.amazonaws.com/serverkaka-pubic-file/redmine/passenger.conf

# create a symlink to connect Redmine into the web document space
ln -s /usr/share/redmine/public /var/www/html/redmine

# Configuring Apache
cd /etc/apache2/sites-available/
rm 000-default.conf
wget https://s3.amazonaws.com/serverkaka-pubic-file/redmine/000-default.conf

# Create and set the ownership of a Gemfile.lock file so that apache's www-data user can access it
touch /usr/share/redmine/Gemfile.lock
chown www-data:www-data /usr/share/redmine/Gemfile.lock

# Adjust the Firewall
ufw allow 80/tcp

# Restart Apache
service apache2 restart

# Set auto start tomcat as a system boot
sudo systemctl enable apache2

echo "Redmine is successfully installed. For Aceess Redmine Go to http://localhost/redmine/
