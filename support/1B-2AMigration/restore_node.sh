#!/bin/sh

die() {
	echo "Failed: $1"
	exit
}

rmolddir() {
	if [ -d $1 ]; then
		echo "Existing $1 directory wiil be removed."
		rm -rf $1
	fi
}

if [ -z "$1" ]; then
	die "Need to know which node is being restored"
fi

if [ ! -d ../redbox ]; then
	die "Wrong working dir. Need to be redbx but instead: `pwd`"
fi

NODE=$1
echo Resotring $NODE
if [ ! -f $NODE.tar.gz ]; then
	die "$NODE.tar.gz does not exits."
fi

rmolddir "solr"
rmolddir "storage"

echo "Extracting sequence.sql, solr and storage"
tar zxf $NODE.tar.gz

if [ ! -f sequence.sql ]; then
	die "sequence.sql does not exits."
fi

if [ ! -f db-derby-10.8.3.0-lib.tar.gz ]; then
	wget http://mirror.ventraip.net.au/apache//db/derby/db-derby-10.8.3.0/db-derby-10.8.3.0-lib.tar.gz
	tar zxf db-derby-10.8.3.0-lib.tar.gz
fi

cd db-derby-10.8.3.0-lib/lib
java -classpath .:derbytools.jar:derby.jar org.apache.derby.tools.ij ../../sequence.sql
cd -

echo "Cleaning up db-derby"
rm -rf  db-derby-10.8.3.0-lib*

echo
echo "Start server, and view it live in browser before run tf_restore.sh to load migrated data"

if [ ! -f change_owner.py ]; then
	echo
	echo "1B operator did not include change_owner.py."
	echo "You can download it from github"
	echo "wget https://raw.githubusercontent.com/qcif/rdsi-arms/master/support/1B-2AMigration/change_owner.py"
fi

