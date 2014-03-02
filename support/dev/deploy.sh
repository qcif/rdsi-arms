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
CUSTOM_ARCHIVE=
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
    echo "Usage: $PROG [options] (redbox | mint) [installArchive]"
    echo "Options:"
    #echo "  -i | --installdir dir  install directory (Warning: not fully working)"
    echo "  -t | --tmpdir dir      directory for install files"
    echo "  -r | --reinstall       force reinstall even if installed version is up-to-date"
    echo "  -d | --download        force download from Nexus even already downloaded"
    echo "  -v | --verbose         print extra information during execution"
    echo "  -h | --help            show this message"
    echo "installArchive           install this tar.gz file instead of from Nexus"
    exit 0
fi
 
if [ $# -eq 0 ]; then
    echo "Usage error: specify \"redbox\" or \"mint\" (\"-h\" for help)" >&2
    exit 2
elif [ $# -eq 1 ]; then
    RB_SYSTEM="$1"
    CUSTOM_ARCHIVE=
elif [ $# -eq 2 ]; then
    RB_SYSTEM="$1"
    CUSTOM_ARCHIVE="$2"
else
    echo "Usage error: too many arguments (\"-h\" for help)$*" >&2
    exit 2
fi
 
#----------------------------------------------------------------
# Check dependencies (some minimal installations do not have these commands)

for COMMAND in tar curl; do

    which $COMMAND >/dev/null 2>&1
    if [ $? -ne 0 ]; then
	echo "$PROG: error: command not available: $COMMAND" >&2
	exit 1
    fi

done

#----------------------------------------------------------------
# Setup variables

#----------------
# Determine IP address

if which ip >/dev/null 2>&1; then
    # ip command available

    # Try to get one IPv4 address that is not 127.0.0.1
    SERVER_IP=`ip -o -f inet addr |
               awk -F'[ /]+' '{print $4}' |
               grep -v 127.0.0.1 |
               sort -n -r |
               head -n 1`
fi

echo "$SERVER_IP" | \
    grep '^[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*\.[0-9][0-9]*$' >/dev/null 2>&1
if [ $? -ne 0 ]; then
    # Give up: use default
    echo "$PROG: warning: could not determine IP address; using 127.0.0.1" >&2
    SERVER_IP=127.0.0.1
fi

#----------------

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
# Obtain install files

if [ -z "$CUSTOM_ARCHIVE" ]; then

    # Use installer archive obtained from Nexus repository, stored in $TMPDIR

    DEPLOY_ARCHIVE="$TMPDIR/$RB_SYSTEM.tar.gz"

    # Obtain last modified date from HTTP header
    # (The gsub substitution is to remove the CR-LF line ending from HTTP.)
    # Example: Tue, 01 Oct 2013 11:52:35 GMT -- http://dev.redboxresearchdata...

    LATEST_VERSION="`curl -s --location --head --url "$DEPLOY_URL" |
        awk -F': ' '/Last-Modified: / {gsub(/[\x0d\x0a]/, "", $2); print $2}'` -- $DEPLOY_URL"

    # Determine if latest version already installed

    if [ -f $INSTDIR/version.txt -a -z "$FORCE_REINSTALL" ]; then
	TS_OLD=`cat $INSTDIR/version.txt`
 
	if [ -n "$VERBOSE" ]; then   
            echo "  Installed version timestamp: $TS_OLD"
            echo "     Latest version timestamp: $LATEST_VERSION"
	fi
    
	if [ "$TS_OLD" = "$LATEST_VERSION" ]; then
            echo "Already running latest version of $RB_SYSTEM"
            exit 0
	fi
    fi

    # Create deployment directory

    if [ ! -d "$TMPDIR" ]; then
	mkdir -p "$TMPDIR" || die
    fi

    # Get latest archive from Nexus repository

    # Get tag of cached install (if it exists)
    EXISTING_VERSION=`cat "$TMPDIR/version.txt" 2>/dev/null`

    if [ -z "$FORCE_DOWNLOAD" -a \
	-f "$DEPLOY_ARCHIVE" -a \
	-f "$TMPDIR/version.txt" -a \
	"$EXISTING_VERSION" = "$LATEST_VERSION" ]; then
	# Use previously downloaded archive

	if [ -n "$VERBOSE" ]; then
            echo "Install file: $RB_SYSTEM: reusing $DEPLOY_ARCHIVE"
	fi
    else
	# Download new archive

	rm -f "$TMPDIR/version.txt" || die
	rm -f "$DEPLOY_ARCHIVE" || die

	echo "Downloading from Nexus: $DEPLOY_ARCHIVE"

	echo $LATEST_VERSION > "$TMPDIR/download-in-progress.txt" || die
	curl -# --location -o "$DEPLOY_ARCHIVE" "$DEPLOY_URL" || die
	mv "$TMPDIR/download-in-progress.txt" "$TMPDIR/version.txt" || die
    fi

else
    # Custom installer archive specified on command line

    if [ ! -f "$CUSTOM_ARCHIVE" ]; then
	echo "$PROG: error: installer archive not found: $CUSTOM_ARCHIVE" >&2
	exit 1
    fi

    DEPLOY_ARCHIVE="$CUSTOM_ARCHIVE"
fi

# Convert DEPLOY_ARCHIVE into a full path name (so it can be found
# after changing the working directory to the install directory).
# Also, since this script is often run as the user 'redbox' via su, it
# might not be able to access the custom archive supplied to it (even
# though the invoker can). So check for that problem too.

DIR="$( cd "$( dirname "$DEPLOY_ARCHIVE" )" && pwd )"
DEPLOY_ARCHIVE_FULL_PATH="$DIR/`basename "$DEPLOY_ARCHIVE"`"

DIRSTR=`dirname "$DEPLOY_ARCHIVE"`
if [ -d "$DIRSTR" -a -r "$DIRSTR" -a -x "$DIRSTR" ]; then
    DIR="$(cd "$DIRSTR" && pwd)"
else
    echo "$PROG: running as user: `id -u -n`" >&2
    echo "$PROG: error: insufficient privileges to access directory: $DIRSTR" >&2
    exit 1
fi
DEPLOY_ARCHIVE_FULL_PATH="$DIR/`basename "$DEPLOY_ARCHIVE"`"
if [ ! -r "$DEPLOY_ARCHIVE_FULL_PATH" ]; then
    echo "$PROG: running as user: `id -u -n`" >&2
    echo "$PROG: error: insufficient privileges to access file: $DEPLOY_ARCHIVE_FULL_PATH" >&2
    exit 1
fi

#----------------------------------------------------------------
# Uninstall (if necessary)

if [ -f $INSTDIR/server/tf.sh ]; then
    echo Stopping $RB_SYSTEM
    $INSTDIR/server/tf.sh stop || die
fi

rm -f $INSTDIR/version.txt || die

# TODO: check this is correct, should delete everything?

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

# Extract into install directory.
#
# The tar has all the files under a directory called "redbox" or "mint",
# so we need to move the contents out of there up a level and remove
# that directory.

if [ -n "$VERBOSE" ]; then
    echo "Extracting $DEPLOY_ARCHIVE into $INSTDIR"
fi

(cd "$INSTDIR" && \
 tar -x -z -f "$DEPLOY_ARCHIVE_FULL_PATH" && \
 mv $RB_SYSTEM/* . && \
 rmdir $RB_SYSTEM) || die

# Fix incorrect URL

sed -i $REGEX "$INSTDIR/server/tf_env.sh" || die

# Record version that has been installed

if [ -z "$CUSTOM_ARCHIVE" ]; then
    # Record timestamp from Nexus
    echo $LATEST_VERSION > "$INSTDIR/version.txt" || die
else
    # Custom archive installed: synthesize version information
    # Example: 2014-02-27T10:05:20+1000 -- file:///home/foobar.tar.gz
    #RB_DATE=`stat -f '%Sm' -t '%FT%T%z' "$DEPLOY_ARCHIVE_FULL_PATH"` #BSD stat
    RB_DATE=`stat -c '%y' "$DEPLOY_ARCHIVE_FULL_PATH"` #GNU stat
    echo "$RB_DATE -- file://$DEPLOY_ARCHIVE_FULL_PATH" > "$INSTDIR/version.txt" || die
fi

# Start

echo "Starting $RB_SYSTEM:"
$INSTDIR/server/tf.sh start || die

#----------------------------------------------------------------
# Installing completed successfully

exit 0

#EOF
