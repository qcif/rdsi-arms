#!/bin/sh
#
# Deploying ARMS from source code.
#
# This script can be used to deploy ARMS on a completely new
# instance of an operating system. It does **everything**: from
# installing Git, downloading the ARMS sources from GitHub,
# building it, through to installing ARMS ReDBox and Mint.
#
# Also can be used to remove ARMS or to show the status.
#
# Requires sudo access to run.
#
#   Usage: arms-deploy.sh (--install | --remove) [src_directory]
#
# Copyright (C) 2014, QCIF Ltd.
#----------------------------------------------------------------

PROG=`basename "$0"`
PROGDIR="$( cd "$( dirname "$0" )" && pwd )"

DEFAULT_SRCDIR=arms

#----------------------------------------------------------------

function deploy_arms () {

    if [ -e "$SRCDIR" ]; then
	echo "Error: directory already exists: $SRCDIR" >&2
	exit 1
    fi

    # Ensure hostname resolves

    HOSTNAME=`hostname`
    ping -c 1 "$HOSTNAME" >/dev/null 2>&1
    if [ $? -ne 0 ]; then
	sudo sh -c "echo \"127.0.0.1  $HOSTNAME\" >> /etc/hosts"
    fi

    # Ensure tar, Java, Maven and Git are available

    # Needed because tar is not in the minimal installation of Fedora 20
    which tar >/dev/null 2>&1
    if [ $? -ne 0 ]; then
	echo "Installing tar"
	sudo yum -q install -y tar
    fi

    which java >/dev/null 2>&1
    if [ $? -ne 0 ]; then
	echo "Installing Java 1.7.0 OpenJDK"

	sudo yum install -y java-1.7.0-openjdk
	echo 'export JAVA_HOME=/usr/lib/jvm/jre' >> ~/.bash_profile
	. ~/.bash_profile
    fi

    which mvn >/dev/null 2>&1
    if [ $? -ne 0 ]; then
	echo "Installing Maven 2.2.1"
	curl -s -O http://archive.apache.org/dist/maven/binaries/apache-maven-2.2.1-bin.tar.gz
	tar xfz apache-maven-2.2.1-bin.tar.gz
	rm apache-maven-2.2.1-bin.tar.gz 
	sudo mv apache-maven-2.2.1 /opt/maven
	echo 'PATH=$PATH:/opt/maven/bin' >> ~/.bash_profile 
	. ~/.bash_profile
	echo $PATH
    fi

    which git >/dev/null 2>&1
    if [ $? -ne 0 ]; then
	echo "Installing git"
	sudo yum -q install -y git
    fi

    # Make directory and get sources

    mkdir "$SRCDIR"
    (cd "$SRCDIR" && git clone https://github.com/qcif/rdsi-arms.git)

    # Build

    (cd "$SRCDIR/rdsi-arms" && mvn clean package -Pbuild-package,dev)

    # Install

    sudo "$SRCDIR/rdsi-arms/support/dev/install-arms.sh" --verbose \
	--install "$SRCDIR"/rdsi-arms/target/redbox-rdsi-arms-*.tar.gz
}

#----------------------------------------------------------------

function remove_arms () {

    if [ ! -e "$SRCDIR" ]; then
	echo "Error: directory does not exist: $SRCDIR" >&2
	exit 1
    fi

    sudo "$SRCDIR/rdsi-arms/support/dev/install-arms.sh" --cleanup --uninstall
    if [ $? -ne 0 ]; then
	echo "Error: install-arms.sh failed"
	exit 1
    fi

    rm -rf "$SRCDIR"
}

#----------------------------------------------------------------

function show_status () {

    if [ -e "/opt/redbox" ]; then
	HAS_REDBOX=yes
    else
	HAS_REDBOX=
    fi

    if [ -e "/opt/mint" ]; then
	HAS_MINT=yes
    else
	HAS_MINT=
    fi

    # Summary output

    if [ -n "$HAS_MINT" -a -n "$HAS_REDBOX" ]; then
	echo "ARMS deployed"
    elif [ -z "$HAS_MINT" -a -z "$HAS_REDBOX" ]; then
	echo "ARMS not deployed"
    else
	echo "ARMS partially deployed"
    fi

    if [ -n "$VERBOSE" ]; then
	# Extra details

	if [ -n "$HAS_REDBOX" ]; then
	    echo "  ReDBox: /opt/redbox"
	fi

	if [ -n "$HAS_MINT" ]; then
	    echo "  Mint: /opt/mint"
	fi

	if [ -e "/tmp/install-arms" ]; then
	    echo "  Installer cache: /tmp/install-arms"
	fi

	if [ -e "$SRCDIR" ]; then
	    echo "  Source: $SRCDIR"
	fi
    fi
}

#================================================================
# Parse command line arguments

HELP=
DO_DEPLOY=
DO_REMOVE=
VERBOSE=
SRCDIR=

getopt -T > /dev/null
if [ $? -eq 4 ]; then
    # GNU enhanced getopt is available
    ARGS=`getopt --name "$PROG" --long help,deploy,remove,verbose --options hdrv -- "$@"`
else
    # Original getopt is available (no long option names, no whitespace, no sorting)
    ARGS=`getopt hdrv "$@"`
fi
if [ $? -ne 0 ]; then
    echo "$PROG: usage error (use -h for help)" >&2
    exit 2
fi
eval set -- $ARGS

while [ $# -gt 0 ]; do
    case "$1" in
        -h | --help)         HELP=yes;;
        -d | --deploy)       DO_DEPLOY=yes;;
        -r | --remove)       DO_REMOVE=yes;;
        -v | --verbose)      VERBOSE=yes;;
        --)                  shift; break;; # end of options
    esac
    shift
done

if [ -n "$HELP" ]; then
    echo "Usage: $PROG [options] [directory]"
    echo "Options:"
    echo "  -d | --deploy      deploy ARMS"
    echo "  -r | --remove      remove ARMS"
    echo "  -v | --verbose     print extra information during execution"
    echo "  -h | --help        show this message"
    exit 0
fi

if [ $# -eq 0 ]; then
    SRCDIR="$DEFAULT_SRCDIR"

elif [ $# -eq 1 ]; then
    SRCDIR="$1"

elif [ $# -gt 1 ]; then
    echo "Usage error: too many arguments (\"-h\" for help)" >&2
    exit 2
fi

#----------------
# Main

if [ -n "$DO_REMOVE" ]; then
    remove_arms
fi

if [ -n "$DO_DEPLOY" ]; then
    deploy_arms
fi

if [ -z "$DO_DEPLOY" -a -z "$DO_REMOVE" ]; then
    # Neither: show status
    show_status
fi

exit 0

#----------------------------------------------------------------
#EOF
