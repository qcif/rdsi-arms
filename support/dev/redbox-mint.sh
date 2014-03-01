#!/bin/sh
echo

if [ "$1" == "" ]; then
  OPT=start;
else
  OPT=$1;
fi
echo ReDBox and Mint will $OPT

/usr/bin/sudo -u redbox /opt/redbox/server/tf.sh $OPT
/usr/bin/sudo -u redbox /opt/mint/server/tf.sh $OPT