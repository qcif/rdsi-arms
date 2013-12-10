#!/bin/sh

usage() {
	if [ `whoami` != 'root' ]; 
		then echo "this script must be executed as root" && exit 1;
	fi
}
usage

userdel -r redbox

rm -Rf /opt/deploy
rm -Rf /opt/redbox
rm -Rf /opt/mint

yum erase unzip
yum erase java
yum erase httpd
