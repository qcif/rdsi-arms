#!/bin/sh
#
# Installer and uninstaller for ARMS.
#
# See "install-arms.md" for documentation.
#
# Copyright (C) 2014, QCIF Ltd.
#----------------------------------------------------------------

PROG=`basename "$0"`
PROGDIR="$( cd "$( dirname "$0" )" && pwd )"

#----------------------------------------------------------------
# Configuration (these can be changed)

APACHE_ARMS_CONFIG=/etc/httpd/conf.d/25-arms.conf

DEFAULT_TMPDIR=/tmp/install-arms

#----------------------------------------------------------------
# Constants (do not change: further work is needed to make these configurable)

REDBOX_INSTDIR=/opt/redbox
MINT_INSTDIR=/opt/mint
INST_USER=redbox

#----------------------------------------------------------------
# Abort after an error has been detected

function die () {
    echo "$PROG: aborted." >&2
    exit 1
}

#----------------------------------------------------------------
# Determine if Mint or ReDBox is ready
# Usage: fascinator_ready {Mint | ReDBox}

function fascinator_ready () {
    FR_TARGET=$1

    if [ "$FR_TARGET" = 'Mint' ]; then
        MAIN_LOG_FILE="$MINT_INSTDIR/home/logs/main.log"
    elif [ "$FR_TARGET" = 'ReDBox' ]; then
        MAIN_LOG_FILE="$REDBOX_INSTDIR/home/logs/main.log"
    else
        echo "$PROG: fascinator_ready: internal error: $FR_TARGET" >&2
        exit 3
    fi

    /bin/echo -n "Waiting for $FR_TARGET to be ready..."

    STARTUP_COMPLETED=
    TIMEOUT=300 # max 5 minutes
    TIMER=0
    while [ $TIMER -lt $TIMEOUT ]; do

        if [ -r "$MAIN_LOG_FILE" ]; then
	    grep 'MessageBroker *All Message Queues started successfully' \
                "$MAIN_LOG_FILE" >/dev/null
            if [ $? -eq 0 ]; then
                # Found the message: assume it has started
                # Is there might be a better (and accurate) way to do this?
                STARTUP_COMPLETED=yes
                break;
            fi
        fi
        sleep 1
        TIMER=`expr $TIMER + 1`
    done

    if [ -n "$STARTUP_COMPLETED" ]; then
        echo " done (${TIMER}s)"
        return 0
    else
        echo
        echo "Warning: timeout: $FR_TARGET not fully running" >&2
        return 1
    fi
}

#----------------------------------------------------------------
# Installs ARMS

function arms_install () {
    
    #----------------
    # Check hostname is resolvable, since this is critical
    # for configuring ARMS and for it to work.

    HOSTNAME=`hostname`
    ping -c 1 "$HOSTNAME" >/dev/null 2>&1
    if [ $? -ne 0 ]; then
	echo "$PROG: cannot resolve this server's hostname: $HOSTNAME" >&2
	exit 1
    fi
    
    #----------------
    # Check if ARMS has not already been installed

    if [ -e "$REDBOX_INSTDIR" ]; then
	echo "$PROG: error: found $REDBOX_INSTDIR: ARMS already installed" >&2
	exit 1
    fi

    if [ -e "$MINT_INSTDIR" ]; then
	echo "$PROG: error: found $MINT_INSTDIR: ARMS already installed" >&2
	exit 1
    fi

    #----------------
    # Check for root privileges

    if [ `id -u` -ne 0 ]; then
	echo "$PROG: error: root privileges required" >&2
	exit 1
    fi

    #----------------
    # Check commands (some minimal installations do not have these installed)
    #
    # Actually some of these are used by the "deploy.sh" script, but
    # it is better to also check for them here and fail-fast instead
    # of waiting until the deploy script is reached.

    for COMMAND in tar curl yum adduser; do

	which $COMMAND >/dev/null 2>&1
	if [ $? -ne 0 ]; then
	    echo "$PROG: error: command not available: $COMMAND" >&2
	    exit 1
	fi

    done

    #----------------

    echo "Installing ARMS (hostname: $HOSTNAME)"

    #----------------
    # Get script and Apache config file.

    if [ ! -d "$TMPDIR" ]; then
	mkdir -p "$TMPDIR" || die
    else
	if [ -n "$VERBOSE" ]; then
	    echo "Install files for ARMS: reusing $TMPDIR"
	fi
    fi

    for FILE in deploy.sh apache-arms.conf; do

	if [ ! -f "$TMPDIR/$FILE" ]; then
	    # File not found in temporary install directory: get it

	    if [ -f "$PROGDIR/$FILE" ]; then
		# Local copy exists: use it
		# This is for when running from the project source directory
	        if [ -n "$VERBOSE" ]; then
		    echo "Copying: $PROGDIR/$FILE -> $TMPDIR/$FILE"
                fi
		cp "$PROGDIR/$FILE" "$TMPDIR/$FILE" || die
	    else
		# Download file from GitHub
		echo "Downloading from GitHub: $TMPDIR/$FILE"
		curl --silent --location -o "$TMPDIR/$FILE" \
		    https://raw.github.com/qcif/rdsi-arms/master/support/dev/$FILE || die
	    fi
	fi
    done

    chmod a+x "$TMPDIR/deploy.sh" || die

    #----------------
    # Install Java and Apache

    YUM_VERBOSE=--quiet # not verbose, so run yum in quiet mode

    for PACKAGE in java-1.7.0-openjdk httpd; do
	rpm -q $PACKAGE >/dev/null 2>&1
	if [ $? -ne 0 ]; then
	    # Package not installed: install it
	    echo "Installing RPM package: $PACKAGE (downloading, please wait)"
	    yum install -y $YUM_VERBOSE $PACKAGE || die
	else
	    # Package already installed
	    if [ -n "$VERBOSE" ]; then
		echo "RPM Package already installed: $PACKAGE"
	    fi
	fi
    done

    #----------------
    # Create user

    id $INST_USER >/dev/null 2>&1
    if [ $? -ne 0 ]; then
	if [ -n "$VERBOSE" ]; then
	    echo "Creating user account: $INST_USER"
	fi
	# User does not exist: create it
	adduser --system $INST_USER || die
    else
	if [ -n "$VERBOSE" ]; then
	    echo "User already exists: $INST_USER"
	fi
    fi

    # Now that the user is definitely available, change the ownerships.
    # The directory must be writable by the user, since the deploy.sh script
    # will expect to be able to write to it.

    chown $INST_USER:$INST_USER "$TMPDIR" || die
    chown $INST_USER:$INST_USER "$TMPDIR/deploy.sh" || die
    chown $INST_USER:$INST_USER "$TMPDIR/apache-arms.conf" || die

    #----------------
    # Common argument to deploy.sh

    if [ -n "$VERBOSE" ]; then
	VERB=-v
    else
	VERB=
    fi

    #----------------
    # Install Mint

    # Create install directory
    mkdir -p "$MINT_INSTDIR" || die
    chown $INST_USER:$INST_USER "$MINT_INSTDIR" || die

    # Download from Nexus (if necessary) and deploy
    su $INST_USER -c "\"$TMPDIR/deploy.sh\" $VERB -t \"$TMPDIR/install-mint\" -i \"$MINT_INSTDIR\" mint" || die

    # Caution: must wait until Mint has fully started up before harvesting.
    fascinator_ready Mint

    # Load ANZSRC FoR codes
    # Caution: the harvester must be run from in the /opt/mint/server directory.
    echo "Loading ANZSRC Field of Research codes into Mint:"
    su $INST_USER -c "cd \"$MINT_INSTDIR/server\" && ./tf_harvest.sh ANZSRC_FOR" || die

    #----------------
    # Install ReDBox

    # Create install directory
    mkdir -p "$REDBOX_INSTDIR" || die
    chown $INST_USER:$INST_USER "$REDBOX_INSTDIR" || die

    if [ -n "$CUSTOM_REDBOX_ARCHIVE" ]; then
        # Make a copy of it so we can ensure that the deploy.sh (which will be
        # running as the redbox user and not root) can always read it.
        CUSTOM_ARCHIVE_TMP="$REDBOX_INSTDIR/redbox-$$.tar.gz"
	if [ -n "$VERBOSE" ]; then
	    echo "Copying: $CUSTOM_REDBOX_ARCHIVE -> $CUSTOM_ARCHIVE_TMP"
        fi
        cp "$CUSTOM_REDBOX_ARCHIVE" "$CUSTOM_ARCHIVE_TMP" || die
        chown $INST_USER:$INST_USER "$CUSTOM_ARCHIVE_TMP" || die
    else
        # Deploy will use the cached installer copy or download it
        CUSTOM_ARCHIVE_TMP=
    fi

    # Download from Nexus (if necessary) and deploy
    su $INST_USER -c "\"$TMPDIR/deploy.sh\" $VERB -t \"$TMPDIR/install-redbox\" -i \"$REDBOX_INSTDIR\" redbox \"$CUSTOM_ARCHIVE_TMP\"" || die

    if [ -n "$CUSTOM_ARCHIVE_TMP" ]; then
        # Delete the copy
        rm "$CUSTOM_ARCHIVE_TMP" || die
    fi

    #----------------
    # Configure Apache

    cp "$TMPDIR/apache-arms.conf" "$APACHE_ARMS_CONFIG" || die

    # Set ServerName in the Apache config file
    sed -i.bak "s/^#ServerName www.example.com:/ServerName $HOSTNAME:/" /etc/httpd/conf/httpd.conf || die

    # Start Apache
    service httpd start || die

    #----------------
    # Wait for ReDBox to be ready

    fascinator_ready ReDBox

    #----------------
    # Priming

    # Priming Mint so it is ready to respond quickly to the first request.
    # This simply gets Tapistry to initialize.
    # Note: if this is not done, the first time ReDBox contacts Mint
    # to get the FoR codes it is very likely to timeout.

    if [ -n "$VERBOSE" ]; then
        /bin/echo -n "Priming Mint..."
    fi
    curl -s -L 'http://localhost:9001/mint/ANZSRC_FOR' >/dev/null || die
    if [ -n "$VERBOSE" ]; then
        echo " done"
    fi

    # Priming ReDBox so it is ready to respond quickly to the first request.
    # This simply gets Tapistry to initialize.
    # This makes it respond faster the first time a user accesses ReDBox.

    if [ -n "$VERBOSE" ]; then
        /bin/echo -n "Priming ReDBox..."
    fi
    curl -s -L 'http://localhost:9000/' >/dev/null || die
    if [ -n "$VERBOSE" ]; then
        echo " done"
    fi

    #----------------
    # Finish up

    if [ -n "$VERBOSE" ]; then
	echo "ARMS installed"
    fi
}


#----------------------------------------------------------------
# Uninstall ARMS

function arms_uninstall () {

    if [ -n "$VERBOSE" ]; then
	echo "Uninstalling ARMS"
    fi

    #----------------
    # Check for root privileges

    if [ `id -u` -ne 0 ]; then
	echo "$PROG: error: root privileges required" >&2
	exit 1
    fi

    #----------------
    # Stop and unconfigure Apache

    service httpd status | grep 'stopped' >/dev/null
    if [ $? -ne 0 ]; then

	service httpd stop || die

	if [ -f "$APACHE_ARMS_CONFIG" ]; then
	    rm "$APACHE_ARMS_CONFIG" || die
	fi

	sed -i.bak "s/^ServerName .*:/#ServerName www.example.com:/" \
	    /etc/httpd/conf/httpd.conf || die
    fi

    #----------------
    # Uninstall ReDBox

    if [ -e "$REDBOX_INSTDIR" ]; then
	if [ -f "$REDBOX_INSTDIR/server/tf.sh" ]; then
	    "$REDBOX_INSTDIR/server/tf.sh" stop || die
	fi
	rm -r "$REDBOX_INSTDIR" || die
    fi

    #----------------
    # Uninstall Mint

    if [ -e "$MINT_INSTDIR" ]; then
	if [ -f "$MINT_INSTDIR/server/tf.sh" ]; then
	    "$MINT_INSTDIR/server/tf.sh" stop || die
	fi
	rm -r "$MINT_INSTDIR" || die
    fi

    #----------------
    # Finish up

    if [ -n "$VERBOSE" ]; then
	echo "ARMS uninstalled"
    fi
}

#----------------------------------------------------------------
# Remove installation files

function arms_cleanup () {
    if [ ! -w "$TMPDIR" ]; then
        echo "$PROG: error: insufficient permissions to clean up: $TMPDIR" >&2
        exit 1
    fi

    # Remove temporary install files

    if [ -d "$TMPDIR" ]; then
	rm -rf "$TMPDIR" || die
    fi

    if [ -n "$VERBOSE" ]; then
	echo "ARMS install files removed"
    fi
}

#================================================================
# Parse command line arguments

HELP=
DO_CLEANUP=
DO_UNINSTALL=
DO_INSTALL=
TMPDIR="$DEFAULT_TMPDIR"
VERBOSE=

getopt -T > /dev/null
if [ $? -eq 4 ]; then
    # GNU enhanced getopt is available
    ARGS=`getopt --name "$PROG" --long help,tmpdir,install,uninstall,cleanup,verbose --options ht:iucv -- "$@"`
else
    # Original getopt is available (no long option names, no whitespace, no sorting)
    ARGS=`getopt ht:iucv "$@"`
fi
if [ $? -ne 0 ]; then
    echo "$PROG: usage error (use -h for help)" >&2
    exit 2
fi
eval set -- $ARGS

while [ $# -gt 0 ]; do
    case "$1" in
        -h | --help)         HELP=yes;;
        -i | --install)      DO_INSTALL=yes;;
        -u | --uninstall)    DO_UNINSTALL=yes;;
        -c | --cleanup)      DO_CLEANUP=yes;;
        -t | --tmpdir)       TMPDIR="$2"; shift;;
        -v | --verbose)      VERBOSE=yes;;
        --)                  shift; break;; # end of options
    esac
    shift
done

if [ -n "$HELP" ]; then
    echo "Usage: $PROG [options] [redboxInstallArchive]"
    echo "Options:"
    echo "  -i | --install     install ARMS (default action)"
    echo "  -u | --uninstall   uninstall ARMS"
    echo "  -c | --cleanup     delete temporary install files"
    echo "  -t | --tmpdir dir  directory for install files (default: $DEFAULT_TMPDIR)"
    echo "  -v | --verbose     print extra information during execution"
    echo "  -h | --help        show this message"
    echo "redboxInstallArchive install this tar.gz file instead of from Nexus"
    exit 0
fi

if [ -z "$DO_INSTALL" -a -z "$DO_UNINSTALL" -a -z "$DO_CLEANUP" ]; then
    # No action explicitly specified: default to install
    DO_INSTALL=yes
fi

if [ $# -eq 0 ]; then
    # No installArchive: use Nexus
    CUSTOM_REDBOX_ARCHIVE=

elif [ $# -eq 1 ]; then

    if [ ! -f "$1" ]; then
	echo "$PROG: error: install archive not found: $1" >&2
	exit 1
    fi
    CUSTOM_REDBOX_ARCHIVE="$1"

    if [ -z "$DO_INSTALL" ]; then
	echo "$PROG: warning: not installing: installArchive ignored: $1" >&2
    fi

elif [ $# -gt 1 ]; then
    echo "Usage error: too many arguments (\"-h\" for help)" >&2
    exit 2
fi

#----------------------------------------------------------------
# Main

# Perform requested action(s).

# Note: this is designed to allow multiple actions to be specified
# and they are each performed in a sensible order.
#
# uninstall + install = reinstall
# install + cleanup = install and remove temporary files
# cleanup + uninstall = remove all trace of ARMS
# cleanup + uninstall + install = redownload and do a fresh reinstall

if [ -n "$DO_CLEANUP" ]; then
    arms_cleanup
fi

if [ -n "$DO_UNINSTALL" ]; then
    arms_uninstall
fi

if [ -n "$DO_INSTALL" ]; then
    arms_install
fi

exit 0

#----------------------------------------------------------------
#EOF
