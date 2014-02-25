#!/bin/sh
#
# Installer for ARMS-ReDBox or Mint.
#
# See "deploy.md" for documentation.
#
# Copyright (C) 2014, QCIF Ltd.
#----------------------------------------------------------------

PROG=`basename $0`

#----------------------------------------------------------------

function die () {
  echo "$PROG: aborted." >&2
  exit 1
}

#----------------------------------------------------------------
# Parse command line arguments

HELP=
TMPDIR=
INSTDIR=
FORCE_REINSTALL=
FORCE_DOWNLOAD=
VERBOSE=

getopt -T > /dev/null
if [ $? -eq 4 ]; then
  # GNU enhanced getopt is available
  ARGS=`getopt --name "$PROG" --long help,tmpdir,installdir:,download,reinstall,verbose --options ht:i:drv -- "$@"`
else
  # Original getopt is available (no long option names, no whitespace, no sorting)
  ARGS=`getopt ht:i:drv "$@"`
fi
if [ $? -ne 0 ]; then
  echo "$PROG: usage error (use -h for help)" >&2
  exit 2
fi
eval set -- $ARGS
 
while [ $# -gt 0 ]; do
    case "$1" in
        -h | --help)         HELP=yes;;
        -t | --tmpdir)       TMPDIR="$2"; shift;;
        -i | --installdir)   INSTDIR="$2"; shift;;
        -r | --reinstall)    FORCE_REINSTALL=yes;;
        -d | --download)     FORCE_DOWNLOAD=yes;;
        -v | --verbose)      VERBOSE=yes;;
        --)                  shift; break;; # end of options
    esac
    shift
done

if [ -n "$HELP" ]; then
    echo "Usage: $PROG [options] (redbox | mint)"
    echo "Options:"
    #echo "  -i | --installdir dir  install directory (Warning: not fully working)"
    echo "  -t | --tmpdir dir      directory for installer files"
    echo "  -r | --reinstall       force reinstall even if installed version is up-to-date"
    echo "  -d | --download        force download from Nexus even if latest already downloaded"
    echo "  -v | --verbose         print extra information during execution"
    echo "  -h | --help            show this message"
    exit 0
fi
 
if [ $# -eq 0 ]; then
  echo "Usage error: missing system: please specify redbox or mint" >&2
  exit 2
elif [ $# -gt 1 ]; then
  echo "Usage error: too many arguments" >&2
  exit 2
else
  RB_SYSTEM="$1"
fi
 
#----------------------------------------------------------------
# Check dependencies (some minimal installations do not have these commands)

# tar

which tar >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "$PROG: error: tar command not found" >&2
    exit 1
fi

# ifconfig
# For example, Fedora 20 minimal install does not have it.
# TODO: change to use "ip addr" instead

which ifconfig >/dev/null 2>&1
if [ $? -ne 0 ]; then
    echo "$PROG: error: ifconfig command not found" >&2
    exit 1
fi

#----------------------------------------------------------------
# Setup variables

# Determine IP address

# TODO: remove CR-LF from value
SERVER_IP=`ifconfig eth0 | awk -F'[: ]+' '/inet addr:/ {print $4}'`

if [ "$SERVER_IP" = "" ]; then
    SERVER_IP=127.0.0.1
fi

case "$RB_SYSTEM" in
    "redbox")
        DEFAULT_INSTDIR=/opt/redbox
        DEFAULT_TMPDIR=/tmp/install-redbox
        DEPLOY_URL="http://dev.redboxresearchdata.com.au/nexus/service/local/artifact/maven/redirect?r=snapshots&g=au.edu.qcif&a=redbox-rdsi-arms&v=LATEST&c=build&e=tar.gz"
        REGEX="s/SERVER_URL=.*/SERVER_URL=http:\/\/$SERVER_IP\//g"
        ;;
    "mint")
        DEFAULT_INSTDIR=/opt/mint
        DEFAULT_TMPDIR=/tmp/install-mint
        DEPLOY_URL="http://dev.redboxresearchdata.com.au/nexus/service/local/artifact/maven/redirect?r=snapshots&g=com.googlecode.redbox-mint&a=mint-local-curation-demo&v=LATEST&c=build&e=tar.gz"
    	REGEX="s/SERVER_URL=.*/SERVER_URL=http:\/\/$SERVER_IP\/${RB_SYSTEM}\//g"
        ;;
    *)
        echo "$PROG: error: unsupported (expecting 'redbox' or 'mint'): $RB_SYSTEM" >&2
        exit 1
        ;;
esac

DEPLOY_ARCHIVE=$RB_SYSTEM.tar.gz

# Set values if not explicitly provided from the command line

if [ -z "$INSTDIR" ]; then
    INSTDIR="$DEFAULT_INSTDIR"
fi
if [ -z "$TMPDIR" ]; then
    TMPDIR="$DEFAULT_TMPDIR" # use default temporary directory
fi

#----------------------------------------------------------------
# Checks

if [ `id -u` -eq 0 ]; then
    echo "$PROG: error: do not run as root (run as the intended user)" >&2
    exit 1
fi

if [ ! -d "$INSTDIR" ]; then
    mkdir -p "$INSTDIR"
    if [ $? -ne 0 ]; then
	echo "$PROG: insufficient privileges for user: `id -u -n`" >&2
	echo "$PROG: could not create install directory: $INSTDIR" >&2
	echo "$PROG: please fix permissions or create it and try again" >&2
	exit 1
    fi
fi
if [ ! -w "$INSTDIR" ]; then
    echo "$PROG: error: install directory not writable: $INSTDIR" >&2
    echo "$PROG: please set permissions for user \"`id -u -n`\" and try again" >&2
    exit 1
fi

#----------------------------------------------------------------
# Display info

if [ -n "$VERBOSE" ]; then
    echo "Installing $RB_SYSTEM (server: $SERVER_IP; directory: $INSTDIR)"
fi

#----------------------------------------------------------------
# Create and change into deployment directory

if [ ! -d "$TMPDIR" ]; then
    mkdir -p "$TMPDIR" || die
fi    
cd "$TMPDIR" || die

#----------------------------------------------------------------
# Work out if we already have the latest version

LATEST_VERSION=`curl -s --location --head --url "$DEPLOY_URL" | \
                awk -F': ' '/Last-Modified: / {print $2}'`

if [ -f $INSTDIR/version.txt -a -z "$FORCE_REINSTALL" ]; then
    TS_OLD=`cat $INSTDIR/version.txt`
 
    if [ -n "$VERBOSE" ]; then   
        echo "  Installed version timestamp: $TS_OLD"
        echo "     Latest version timestamp: $LATEST_VERSION"
    fi
    
    if [ "$TS_OLD" = "$LATEST_VERSION" ]; then
        echo "Already running latest version"
        exit 0
    fi
fi

#----------------------------------------------------------------
# Obtain install files

# Clean up from any aborted installs

rm -rf $TMPDIR/$RB_SYSTEM || die

# Get latest archive

EXISTING_VERSION=`cat version.txt 2>/dev/null`

if [ -z "$FORCE_DOWNLOAD" -a \
     -f $DEPLOY_ARCHIVE -a \
     -f version.txt -a \
     "$EXISTING_VERSION" = "$LATEST_VERSION" ]; then
    # Use previously downloaded archive

    if [ -n "$VERBOSE" ]; then
        echo "Installer file for $RB_SYSTEM: reusing $TMPDIR/$DEPLOY_ARCHIVE"
    fi
else
    # Download new archive

    rm -f version.txt || die
    rm -f $DEPLOY_ARCHIVE || die

    echo "Installer file for $RB_SYSTEM: downloading from Nexus into $TMPDIR"
    if [ -n "$VERBOSE" ]; then
	echo "  $DEPLOY_URL"
    fi
    curl -# --location -o $DEPLOY_ARCHIVE "$DEPLOY_URL" || die

    echo $LATEST_VERSION > version.txt || die
fi

# Extract and fix incorrect URL

tar xzf $DEPLOY_ARCHIVE || die
sed -i $REGEX $RB_SYSTEM/server/tf_env.sh || die

#----------------------------------------------------------------
# Uninstall (if necessary)

if [ -f $INSTDIR/server/tf.sh ]; then
    echo Stopping $RB_SYSTEM
    $INSTDIR/server/tf.sh stop || die
fi

rm -f $INSTDIR/version.txt || die

if [ -d $INSTDIR/server/lib ]; then
    echo Removing $INSTDIR/server/lib
    rm -rf $INSTDIR/server/lib || die
fi
if [ -d $INSTDIR/server/plugin ]; then
    echo Removing $INSTDIR/server/plugin
    rm -rf $INSTDIR/server/plugin || die
fi

#----------------------------------------------------------------
# Install new version

if [ -n "$VERBOSE" ]; then
    echo Copying files across
fi
cp -rf $TMPDIR/$RB_SYSTEM/* $INSTDIR/ || die

echo "Starting $RB_SYSTEM:"
$INSTDIR/server/tf.sh start || die

echo $LATEST_VERSION > $INSTDIR/version.txt || die

#----------------------------------------------------------------
# Installing completed successfully

# Remove extracted files
rm -rf $TMPDIR/$RB_SYSTEM || die

exit 0

#EOF
