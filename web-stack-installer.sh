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
PACK=''
P_APACHE='off'
P_PHP='off'
P_MYSQL='off'
P_COMPOSER='off'
P_NODEJS='off'
P_GRUNT='off'
P_MONGODB='off'

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

_install_monogodb() {
	echo "Install grunt"
	P_MONGODB='on'

	$DEBUG $SUDO apt-key adv --keyserver hkp://keyserver.ubuntu.com:80 --recv EA312927
	$DEBUG echo "deb http://repo.mongodb.org/apt/ubuntu trusty/mongodb-org/3.2 multiverse" | $DEBUG $SUDO tee /etc/apt/sources.list.d/mongodb-org-3.2.list
	$DEBUG $SUDO $PM update
	$DEBUG $SUDO $PM $INSTALL -y mongodb-org

	if [ $(which php) ]; then
		$DEBUG $SUDO $PM $INSTALL php5-dev
		$DEBUG $SUDO pecl install mongodb
		$DEBUG echo "extension=mongodb.so" | $DEBUG $SUDO tee /etc/php5/mods-available/mongodb.ini
		$DEBUG $SUDO php5enmod mongodb
	fi
}

_init_laravel_stack() {
	echo "Setup Laravel Stack"

	P_APACHE='on'
	P_PHP='on'
	P_MYSQL='on'
	P_COMPOSER='on'
	P_NODEJS='on'

}

_modify_stack() {
	dialog --checklist "Modifty Stack:" 15 40 10 \
	"Apache2" Apache2 "$P_APACHE" \
	"PHP" PHP "$P_PHP" \
	"MySql" MySql "$P_MYSQL" \
	"Composer" Composer "$P_COMPOSER" \
	"NodeJs" NodeJS "$P_NODEJS" \
	"MongoDB" MongoDB "$P_MONGODB" \
	"Grunt" Grunt "$P_GRUNT" \
	2> $tempfile
	
	PACK=$(cat $tempfile)

	case $? in
	  0)
	    echo $PACK ;;
	  1)
	    exit ;;
	  255)
	    exit ;;
	esac
}

_install() {
	if [[ $PACK == *"Apache2"* ]]
	then
		_install_apache
	fi

	if [[ $PACK == *"PHP"* ]]
	then
		_install_php
	fi

	if [[ $PACK == *"MySql"* ]]
	then
		_install_mysql
	fi

	if [[ $PACK == *"Composer"* ]]
	then
		_install_composer
	fi

	if [[ $PACK == *"NodeJs"* ]]
	then
		_install_nodejs
	fi

	if [[ $PACK == *"Grunt"* ]]
	then
		_install_grunt
	fi

	if [[ $PACK == *"MongoDB"* ]]
	then
		_install_monogodb
	fi
}

_init_web_stack() {
	# $SUDO $PM $UPDATE
	if [ "$webstack" = "Laravel" ]
	then
		_init_laravel_stack
	elif [ "$webstack" = "Custom" ]
	then
		echo "Custom"
	else
		exit
	fi

	_modify_stack
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