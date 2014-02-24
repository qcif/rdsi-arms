#!/bin/sh

# Make sure /etc/sudoers has the following setting:
# Defaults       always_set_home

#----------------------------------------------------------------

PROG=`basename $0`

function die () {
  echo "$PROG: aborted." >&2
  exit 1
}

#----------------------------------------------------------------
# Parse command line arguments

HELP=
INSTALL_DIR=
FORCE_REINSTALL=
VERBOSE=

getopt -T > /dev/null
if [ $? -eq 4 ]; then
  # GNU enhanced getopt is available
  ARGS=`getopt --name "$PROG" --long help,installdir:,force,verbose --options hi:fv -- "$@"`
else
  # Original getopt is available (no long option names, no whitespace, no sorting)
  ARGS=`getopt hi:fv "$@"`
fi
if [ $? -ne 0 ]; then
  echo "$PROG: usage error (use -h for help)" >&2
  exit 2
fi
eval set -- $ARGS
 
while [ $# -gt 0 ]; do
    case "$1" in
        -h | --help)         HELP=yes;;
        -i | --installdir)   INSTALL_DIR="$2"; shift;;
        -f | --force)        FORCE_REINSTALL=yes;;
        -v | --verbose)      VERBOSE=yes;;
        --)                  shift; break;; # end of options
    esac
    shift
done

if [ -n "$HELP" ]; then
    echo "Usage: $PROG [options] (redbox | mint)"
    echo "Options:"
    echo "  -i | --installdir dir  installation directory (default: /opt/redbox or /opt/mint)"
    echo "  -v | --verbose         verbose output"
    echo "  -f | --force           force reinstall even if up-to-date"
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
# Setup variables

case "$RB_SYSTEM" in
    "redbox")
        if [ -z "$INSTALL_DIR" ]; then
            INSTALL_DIR=/opt/redbox
        fi
        DEPLOY_DIR=/tmp/redbox-install
        DEPLOY_URL="http://dev.redboxresearchdata.com.au/nexus/service/local/artifact/maven/redirect?r=snapshots&g=au.edu.qcif&a=redbox-rdsi-arms&v=LATEST&c=build&e=tar.gz"
        REGEX="s/SERVER_URL=.*/SERVER_URL=http:\/\/$SERVER_IP\//g"
        ;;
    "mint")
        if [ -z "$INSTALL_DIR" ]; then
            INSTALL_DIR=/opt/mint
        fi
        DEPLOY_DIR=/tmp/mint-install
        DEPLOY_URL="http://dev.redboxresearchdata.com.au/nexus/service/local/artifact/maven/redirect?r=snapshots&g=com.googlecode.redbox-mint&a=mint-local-curation-demo&v=LATEST&c=build&e=tar.gz"
    	REGEX="s/SERVER_URL=.*/SERVER_URL=http:\/\/$SERVER_IP\/${RB_SYSTEM}\//g"
        ;;
    *)
        echo "$PROG: error: unsupported system (expecting 'redbox' or 'mint'): $RB_SYSTEM" >&2
        exit 1
        ;;
esac

DEPLOY_ARCHIVE=$RB_SYSTEM.tar.gz

#----------------------------------------------------------------
# Check user

if [ "$USER" != "redbox" ]; then
    echo "$PROG: error: must be run as the 'redbox' user" >&2
    exit 1
fi

#----------------------------------------------------------------
# Determine IP address

SERVER_IP=`ifconfig eth0 | awk -F'[: ]+' '/inet addr:/ {print $4}'`

if [ "$SERVER_IP" = "" ]; then
    SERVER_IP=127.0.0.1;
fi

#----------------------------------------------------------------
# Display info

if [ -n "$VERBOSE" ]; then
    echo "Installing $RB_SYSTEM"
    echo "  SERVER_IP: $SERVER_IP"
    echo "  INSTALL_DIR: $INSTALL_DIR"
    echo "  DEPLOY_DIR: $DEPLOY_DIR"
    echo "  DEPLOY_URL: $DEPLOY_URL"
fi

#----------------------------------------------------------------
# Create and change into deployment directory

if [ ! -d "$DEPLOY_DIR" ]; then
    mkdir -p "$DEPLOY_DIR" || die
fi    
cd "$DEPLOY_DIR" || die

#----------------------------------------------------------------
# Work out if we already have the latest version

LATEST_VERSION=`curl -s --location --head --url "$DEPLOY_URL" | \
                awk -F': ' '/Last-Modified: / {print $2}'`

if [ -f $INSTALL_DIR/version.txt -a -z "$FORCE_REINSTALL" ]; then
    TS_OLD=`cat $INSTALL_DIR/version.txt`
 
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

rm -rf $DEPLOY_DIR/$RB_SYSTEM || die

# Get latest archive

EXISTING_VERSION=`cat $DEPLOY_DIR/version.txt 2>/dev/null`

if [ -f $DEPLOY_ARCHIVE -a \
     -f $DEPLOY_DIR/version.txt -a \
     "$EXISTING_VERSION" = "$LATEST_VERSION" ]; then
    # Use previously downloaded archive

    if [ -n "$VERBOSE" ]; then
        echo "Installing from existing archive: $DEPLOY_ARCHIVE"
    fi
else
    # Download new archive

    rm -f $DEPLOY_DIR/version.txt || die
    rm -f $DEPLOY_ARCHIVE || die

    echo "Downloading $RB_SYSTEM from Nexus"
    curl -# --location -o $DEPLOY_ARCHIVE "$DEPLOY_URL" || die

    echo $LATEST_VERSION > $DEPLOY_DIR/version.txt || die
fi

# Extract and fix incorrect URL

tar xzf $DEPLOY_ARCHIVE || die
sed -i $REGEX $DEPLOY_DIR/$RB_SYSTEM/server/tf_env.sh || die

#----------------------------------------------------------------
# Uninstall (if necessary)

if [ -f $INSTALL_DIR/server/tf.sh ]; then
    echo Stopping $RB_SYSTEM
    $INSTALL_DIR/server/tf.sh stop || die
fi

rm -f $INSTALL_DIR/version.txt || die

if [ -d $INSTALL_DIR/server/lib ]; then
    echo Removing $INSTALL_DIR/server/lib
    rm -rf $INSTALL_DIR/server/lib || die
fi
if [ -d $INSTALL_DIR/server/plugin ]; then
    echo Removing $INSTALL_DIR/server/plugin
    rm -rf $INSTALL_DIR/server/plugin || die
fi

#----------------------------------------------------------------
# Install new version

echo Copying files across
cp -rf $DEPLOY_DIR/$RB_SYSTEM/* $INSTALL_DIR/ || die

echo Starting $RB_SYSTEM
$INSTALL_DIR/server/tf.sh start || die

echo $LATEST_VERSION > $INSTALL_DIR/version.txt || die

#----------------------------------------------------------------
# Installing completed successfully

# Remove extracted files
rm -rf $DEPLOY_DIR/$RB_SYSTEM || die

exit 0

#EOF
