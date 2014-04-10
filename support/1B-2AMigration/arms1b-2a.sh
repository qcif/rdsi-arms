#!/bin/sh
#
# Migrate records from ARMS 1B to 2A.
#
#
# Usage: arms1b-2a.sh
#
# Copyright (C) 2014, QCIF Ltd.
#----------------------------------------------------------------

# usage:
#    arms1b-2a nodename
#

help()
{
cat << eof
Working directory has to be one level above stroage: e.g. /opt/redbox
Usage: $0 nodename
eof
}

die() {
    echo $@ >&2
    exit 1
}

if [ -z $1 ]; then
    help
    die "Node name is needed"
fi
NodeName=$1

workingDir=`pwd` 
storageDir='storage/1793582ab247f6442162a75562dcc548'
scriptDir=/home/li/Documents/redbox-dev/ARMS333

if [ ! -d $storageDir ]; then
	echo "$storageDir does not exist in $workingDir"
	exit 0
fi

PATTERN="jsonConfigPid=arms-"
echo "grep -rl $PATTERN $storageDir/*"

grep -r $PATTERN $storageDir/* | python $scriptDir/filter_node.py $NodeName
if [ $? -gt 0 ]; then
	die "Failed to filter records for $NodeName. Fix previous error. Maybe just no records?"
fi

grep -rl arms-$NodeName $workingDir/$NodeName/$storageDir/* | xargs sed -i s/arms-$NodeName/arms/
grep -rl arms-$NodeName $workingDir/$NodeName/$storageDir/*
if [ $? -eq 1 ]; then
	echo "job might successfully completed: no arms-$NodeName found from $workingDir/$NodeName/$storageDir"
fi
tar zxf $scriptDir/rule_files.tar.gz -C $workingDir/$NodeName/$storageDir/ || die "failed to extract rule files"

# Prepare package for node people
cp -rp $workingDir/solr $workingDir/$NodeName/
cd $NodeName/
tar zcf $NodeName.tar.gz *
cd -
mv $NodeName/$NodeName.tar.gz .
echo "Give this to node operator"
ls -l $NodeName.tar.gz
