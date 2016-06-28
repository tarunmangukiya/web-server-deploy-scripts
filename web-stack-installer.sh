#!/bin/bash
DIALOG=${DIALOG=dialog}
tempfile=`tempfile 2>/dev/null` || tempfile=/tmp/wsitest$$
trap "rm -f $tempfile" 0 1 2 5 15
DEBUG=${DEBUG=echo} # for debug
SUDO=${SUDO=sudo}
PM=${PM=echo}
PM=${PM=apt-get}
UPDATE=${UPDATE=update}
INSTALL=${INSTALL=install -y}

# PACKAGES
P_APACHE='off'
P_PHP='off'
P_MYSQL='off'
P_COMPOSER='off'
P_NODEJS='off'
P_GRUNT='off'

# Global veriable
webstack=''

# select web stack
#------------------------------------------------------

_choose_web_stack() {	
	$DIALOG --backtitle "Web Stack" \
	  --radiolist "Select Web Stack" 10 80 2 \
	        "Laravel" "Apache PHP MySql Composer NPM Bower" off \
	        "Custom" "" on 2> $tempfile

	choice=$(cat $tempfile)

	case $? in
	  0)
	    webstack=$choice ;;
	  1)
	    exit ;;
	  255)
	    exit ;;
	esac
}

_install_apache() {
	echo "Install Apache"
	P_APACHE='on'

	$DEBUG $SUDO $PM $INSTALL python-software-properties apache2
}

_install_php() {
	echo "Install PHP"
	P_PHP='on'

	$DEBUG $SUDO $PM $INSTALL python-software-properties php5 php5-mcrypt

	if [ "$P_APACHE" != "off" ]
	then
		$DEBUG $SUDO $PM $INSTALL libapache2-mod-php5
	fi

}

_install_mysql() {
	echo "Install MySql"
	P_MYSQL='on'

	$DEBUG $SUDO $PM $INSTALL python-software-properties mysql-server-5.6

	if [ "$P_PHP" != "off" ]
	then
		$DEBUG $SUDO $PM $INSTALL php5-mysql
	fi

}

_install_composer() {
	echo "Install Composer"
	P_COMPOSER='on'

	if [ "$P_PHP" != "off" ]
	then
		$DEBUG curl -sS https://getcomposer.org/installer | php
		$DEBUG $SUDO mv composer.phar /usr/local/bin/composer
		$DEBUG $SUDO chmod +x /usr/local/bin/composer
	fi
}

_install_nodejs() {
	echo "Install NodeJS"
	P_NODEJS='on'

	$DEBUG wget https://nodejs.org/dist/v4.4.6/node-v4.4.6-linux-x64.tar.xz
	$DEBUG pushd .
	$DEBUG cd /usr/local
	$DEBUG $SUDO tar --strip-components 1 -xvf node-v4.4.6-linux-x64.tar.xz
	$DEBUG popd
}

_install_grunt() {
	echo "Install grunt"
	P_GRUNT='on'

	$DEBUG $SUDO npm install -g grunt-cli
}

_setup_laravel_stack() {
	echo "Setup Laravel Stack"

	P_APACHE='on'
	P_PHP='on'
	P_MYSQL='on'
	P_COMPOSER='on'
	P_NODEJS='on'

	dialog --checklist "Modifty Stack:" 15 40 5 \
	"Apache2" Apache2 on \
	"PHP" PHP on \
	"MySql" MySql on \
	"Composer" Composer on \
	"NodeJs" NodeJS on 2> $tempfile
	# 6 GRUNT $P_GRUNT \
	
	choice=$(cat $tempfile)

	case $? in
	  0)
	    webstack=$choice ;;
	  1)
	    exit ;;
	  255)
	    exit ;;
	esac

	echo $choice
	echo $P_APACHE
}

_install() {
	echo $P_APACHE
	if [ "$P_APACHE" != "off" ]
	then
		_install_apache
	fi

	if [ "$P_PHP" != "off" ]
	then
		_install_php
	fi

	if [ "$P_MYSQL" != "off" ]
	then
		_install_mysql
	fi

	if [ "$P_COMPOSER" != "off" ]
	then
		_install_composer
	fi

	if [ "$P_NODEJS" != "off" ]
	then
		_install_nodejs
	fi

	if [ "$P_GRUNT" != "off" ]
	then
		_install_grunt
	fi
}

_init_web_stack() {
	# $SUDO $PM $UPDATE
	if [ "$webstack" = "Laravel" ]
	then
		_setup_laravel_stack
	elif [ "$webstack" = "Custom" ]
	then
		echo "Custom"
	else
		exit
	fi

	_install
}

_main () {
	$DEBUG pushd .
	$DEBUG cd /tmp

	_choose_web_stack
	
	if [ "$webstack" != "" ]
	then
		_init_web_stack
	else
		echo "no"
	fi

	$DEBUG popd

}

_main
# rm /tmp/wsitest*