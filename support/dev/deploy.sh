#!/bin/sh

# Make sure /etc/sudoers has the following setting:
# Defaults       always_set_home

if [ "$USER" != "redbox" ]; then
    echo "Must be run as redbox user"
    exit 1;
fi

RB_SYSTEM=$1
case "$RB_SYSTEM" in
    "redbox")
        echo Deploying ReDBox
        INSTALL_DIR=/opt/redbox
        DEPLOY_DIR=/opt/deploy/redbox
        DEPLOY_URL="http://dev.redboxresearchdata.com.au/nexus/service/local/artifact/maven/redirect?r=snapshots&g=au.edu.qcif&a=redbox-rdsi-arms&v=LATEST&c=build&e=tar.gz"
        ;;
    "mint")
        echo Deploying Mint
        INSTALL_DIR=/opt/mint
        DEPLOY_DIR=/opt/deploy/mint
        DEPLOY_URL="http://dev.redboxresearchdata.com.au/nexus/service/local/artifact/maven/redirect?r=snapshots&g=com.googlecode.redbox-mint&a=mint-local-curation-demo&v=LATEST&c=build&e=tar.gz"
        ;;
    *)
        echo Cannot support deployment of: $RB_SYSTEM
        exit 1
        ;;
esac

SERVER_IP=`ifconfig eth0 | awk -F'[: ]+' '/inet addr:/ {print $4}'`

if [ "$SERVER_IP" = "" ]; then
    SERVER_IP=127.0.0.1;
fi

DEPLOY_ARCHIVE=$RB_SYSTEM.tar.gz

echo SERVER_IP: $SERVER_IP
echo INSTALL_DIR: $INSTALL_DIR
echo DEPLOY_DIR: $DEPLOY_DIR
echo DEPLOY_URL: $DEPLOY_URL

if [ ! -d $DEPLOY_DIR ]; then
    mkdir $DEPLOY_DIR
fi    
cd $DEPLOY_DIR

#Work out if we already have the latest version
curl -# --location --head --url "$DEPLOY_URL" | awk -F': ' '/Last-Modified: / {print $2}'>~/$RB_SYSTEM.timestamp.new
if [ -f ~/$RB_SYSTEM.timestamp.old ]; then
    TS_OLD=`cat ~/$RB_SYSTEM.timestamp.old`
    TS_NEW=`cat ~/$RB_SYSTEM.timestamp.new`
    
    echo Old timestamp is: $TS_OLD
    echo New timestamp is: $TS_NEW
    
    if [ "$TS_OLD" = "$TS_NEW" ]; then
        echo "Already running latest version"
        exit;
    fi;    
    
fi

mv -f ~/$RB_SYSTEM.timestamp.new ~/$RB_SYSTEM.timestamp.old

echo Downloading latest version from Nexus: $DEPLOY_URL
wget  "$DEPLOY_URL" -O $DEPLOY_ARCHIVE
tar xzf $DEPLOY_ARCHIVE


REGEX="s/SERVER_URL=.*/SERVER_URL=http:\/\/$SERVER_IP\/$RB_SYSTEM\//g"
echo "Fixing the incorrect url: $REGEX"
sed $REGEX $RB_SYSTEM/server/tf_env.sh > $RB_SYSTEM/server/tf_env.new

mv $RB_SYSTEM/server/tf_env.new $RB_SYSTEM/server/tf_env.shcd 

if [ -f $INSTALL_DIR/server/tf.sh ]; then
    echo Stopping $RB_SYSTEM
    $INSTALL_DIR/server/tf.sh stop;
fi

echo Removing old server libraries
if [ -d $INSTALL_DIR/server/lib ]; then
    echo Removing $INSTALL_DIR/server/lib
    rm -rf $INSTALL_DIR/server/lib
fi
if [ -d $INSTALL_DIR/server/plugin ]; then
    echo Removing $INSTALL_DIR/server/plugin
    rm -rf $INSTALL_DIR/server/plugin
fi

echo Copying files across
cp -rf $RB_SYSTEM/* $INSTALL_DIR/

echo Starting $RB_SYSTEM
$INSTALL_DIR/server/tf.sh start

echo Cleaning up
rm -rf $DEPLOY_DIR/$RB_SYSTEM
exit
