#!/bin/bash

# How To Install Linux, Apache, MySQL, PHP (LAMP) stack on Ubuntu 16.04
# https://www.digitalocean.com/community/tutorials/how-to-install-linux-apache-mysql-php-lamp-stack-on-ubuntu-16-04

# PHP My Admin Secure
# https://www.digitalocean.com/community/tutorials/how-to-install-and-secure-phpmyadmin-on-ubuntu-16-04

# =================================================
# At many places it will ask for your inputs for using disk space
# or for configurations
# =================================================

# Update
sudo apt-get update

# Install cURL & ZIP/UNZIP
sudo apt-get install curl
sudo apt-get install zip unzip

# Install Apache
sudo apt-get install apache2
# Y to allow to use disk space
echo "Apache Installed Successfully!"

# Check Firewall Configurations
echo "Your firewall configuration is."
sudo ufw app list
sudo ufw app info "Apache Full"
sudo ufw allow in "Apache Full"
sudo ufw allow 22
sudo ufw allow 80
sudo ufw allow 443

echo "You can check whether the apache is installed properly by accessing public URL/server IP address."
# If you can see the page then Apache installation is successful.

# To Remove Existing MySQL Server
#sudo apt-get remove --purge mysql-server mysql-client mysql-common
#sudo apt-get remove --purge mysql-*
#sudo apt-get autoremove
#sudo apt-get autoclean
# Other Important Commands
# sudo dpkg --configure mysql-server-5.5


# Install MySQL Server
sudo apt-get install mysql-server
# Y to allow to use disk space
# Enter password for MySQL Root User, Please remeber the password. (Sample ROOT Password: T1umoN23X8W9tPAlQS9)

sudo mysql_secure_installation
# This asks you if you want to enable secured password for your server.
# Press y|Y, if you want to allow VALIDATE PASSWORD PLUGIN to be used.
# If you select Yes, then it will ask you for password strength
# And to reset password if required (Sample Secure Password : Haksfuh@sfeGa23VhP3)

echo "MySQL Server Installed Successfully!"

# Install PHP
sudo apt-get install php libapache2-mod-php php-mcrypt php-mysql
# Y to allow to use disk space

# Inform Apache to prefer php files over html files
# sudo nano /etc/apache2/mods-enabled/dir.conf
# Move the index.php at first place

# Install PHP Required Extensions
sudo apt-get install php-cli php-mbstring php-gettext php-curl
sudo phpenmod mcrypt
sudo phpenmod mbstring
sudo phpenmod curl
echo "php-cli, curl, mcrypt, mbstring Installed Successfully!"

sudo a2enmod rewrite
sudo a2enmod ssl

# Install PHP Dev
sudo apt install php7.0-dev
echo "php7.0-dev Installed Successfully!"

sudo apt-get install php7.0-intl
echo "php7.0-intl Installed Successfully!"

# Install PHP Zip Extension
# sudo apt-get install php7.0-zip
# echo "PHP Zip Extension Installed Successfully!"


# Restart Apache Server
sudo systemctl restart apache2
# To See Apache Status
# sudo systemctl status apache2

echo "Your Home Directory is /var/www/html/. You can start using that Home Directory."

# PHPMyAdmin & Other Extensions
echo "Installing PHPMyAdmin for DB Access & Other Extensions."
sudo apt-get install phpmyadmin
# For the server selection, choose apache2.
# Select yes when asked whether to use dbconfig-common to set up the database
# You will be prompted for your database administrator's password
# You will then be asked to choose and confirm a password for the phpMyAdmin application itself

# =================================================
# Installing Laravel Specific and other required things
# such as Git, Composer, Redis for easy PHP Development
# =================================================

# Install Redis
# We will need to compile redis from its source. Thus need to install other two packages
sudo apt-get install build-essential
sudo apt-get install tcl8.5

cd /usr/local/bin
sudo wget http://download.redis.io/releases/redis-3.2.0.tar.gz
sudo tar xzf redis-3.2.0.tar.gz
cd redis-3.2.0
sudo make
sudo make test
sudo make install
cd utils
sudo ./install_server.sh
echo "Redis Server Installed Successfully!"
# To Start/Stop Server
# sudo service redis_6379 start
# sudo service redis_6379 stop
echo "Disable Redis to listen 127.0.0.1 for security purposes."
sudo nano /etc/redis/6379.conf

sudo update-rc.d redis_6379 defaults
echo "Redis Server Set to Start at boot!"

# Install GIT
sudo apt-get install git
echo "Git Installed Successfully!"
git config --global user.name "Your Name"
git config --global user.email "youremail@domain.com"

# Install Composer
curl -sS https://getcomposer.org/installer | sudo php -- --install-dir=/usr/local/bin --filename=composer
echo "Composer Installed Successfully!"

# Install Supervisord
# https://www.digitalocean.com/community/tutorials/how-to-install-and-manage-supervisor-on-ubuntu-and-debian-vps
sudo apt-get install supervisor
sudo service supervisor restart
# Can add the superviser configs to /etc/supervisor/conf.d
# sudo supervisorctl reread
# sudo supervisorctl update

# ==================================================
# Attach a new HDD and mount it to var/www
# ==================================================
sudo lshw -C disk
sudo fdisk /dev/sdc
# Default inputs sequence
# n = new partition
#    p = primary
# w = write to partition table & exit
# p = view partitions
# Format disk
sudo mkfs -t ext3 /dev/sdc1
# Mount disk
sudo mount /dev/sdc1 /var/www/folder
# Automatic mount at startup, Add this line to file
# sudo nano -Bw /etc/fstab
# /dev/sdc1   /var/www/folder   ext3    defaults     0        2
# Change owner of disk
sudo chown -R root:root /var/www/folder


# ==================================================
# Google Page Speed Module install
# ==================================================
sudo dpkg -i mod-pagespeed-*.deb
sudo apt-get -f install

# ==================================================
# Create Virtual Host for the server
# ==================================================

# Downloading Script to Create Virutal Hosts
cd /usr/local/bin
sudo wget -O virtualhost https://raw.githubusercontent.com/RoverWire/virtualhost/master/virtualhost.sh
sudo chmod +x virtualhost

# Set Virtual Host Name
sudo virtualhost create mysite.dev
sudo systemctl restart apache2

# Git Clone your Site
git clone https://github.com/git/git.git /var/www/mysite.dev

# Composer Update
cd /var/www/mysite.dev
composer install


# ==================================================
# Add a Monitor to keep MySQL, Apache, Supervisor, Redis started in case of any failure
# ==================================================

# https://www.digitalocean.com/community/tutorials/how-to-use-a-simple-bash-script-to-restart-server-programs