#!/bin/sh
#
# Installer and uninstaller for ARMS.
#
# See "install-arms.md" for documentation.
#
# Copyright (C) 2014, QCIF Ltd.
#----------------------------------------------------------------

PROG=`basename "$0"`

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
	echo "$PROG: error: ARMS already installed: found $REDBOX_INSTDIR" >&2
	exit 1
    fi

    if [ -e "$MINT_INSTDIR" ]; then
	echo "$PROG: error: ARMS already installed: found $MINT_INSTDIR" >&2
	exit 1
    fi

    #----------------
    # Check for root privileges

    if [ `id -u` -ne 0 ]; then
	echo "$PROG: error: root privileges required" >&2
	exit 1
    fi

    echo "Installing ARMS (hostname: $HOSTNAME)"

    #----------------
    # Get script and Apache config file.
    # Change working directory to the $TMPDIR.

    if [ ! -d "$TMPDIR" ]; then
	echo "Installer files for ARMS: downloading to $TMPDIR"
	mkdir -p "$TMPDIR" || die
        chown $INST_USER:$INST_USER "$TMPDIR" || die
    else
	if [ -n "$VERBOSE" ]; then
	    echo "Installer files for ARMS: reusing $TMPDIR"
	fi
    fi

    cd "$TMPDIR" || die

    if [ ! -f "$TMPDIR/deploy.sh" ]; then
	echo "Downloading installer file: deploy.sh"
	curl -# --location -o "$TMPDIR/deploy.sh" \
	    https://raw.github.com/qcif/rdsi-arms/master/support/dev/deploy.sh || die
	chmod a+x "$TMPDIR/deploy.sh" || die
        chown $INST_USER:$INST_USER "$TMPDIR/deploy.sh" || die
    fi

    if [ ! -f "$TMPDIR/apache" ]; then
	echo "Downloading installer file: apache"
	curl -# --location -o "$TMPDIR/apache" \
	    https://raw.github.com/qcif/rdsi-arms/master/support/dev/apache || die
        chown $INST_USER:$INST_USER "$TMPDIR/apache" || die
    fi

    #----------------
    # Install Java and Apache

    YUM_VERBOSE=--quiet # not verbose, so run yum in quiet mode

    for PACKAGE in java-1.7.0-openjdk httpd; do
	rpm -q $PACKAGE >/dev/null 2>&1
	if [ $? -ne 0 ]; then
	    if [ -n "$VERBOSE" ]; then
		echo "Installing RPM package: $PACKAGE (downloading, please wait)"
	    fi
	    yum install -y $YUM_VERBOSE $PACKAGE || die
	else
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

    # Load ANZSRC FoR codes
    sudo -u $INST_USER "$MINT_INSTDIR/server/tf_harvest.sh" ANZSRC_FOR || die

    #----------------
    # Install ReDBox

    # Create install directory
    mkdir -p "$REDBOX_INSTDIR" || die
    chown $INST_USER:$INST_USER "$REDBOX_INSTDIR" || die

    # Download from Nexus (if necessary) and deploy
    su $INST_USER -c "\"$TMPDIR/deploy.sh\" $VERB -t \"$TMPDIR/install-redbox\" -i \"$REDBOX_INSTDIR\" redbox" || die

    #----------------
    # Configure Apache

    cp "$TMPDIR/apache" "$APACHE_ARMS_CONFIG" || die

    # Set ServerName in the Apache config file
    sed -i.bak "s/^#ServerName www.example.com:/ServerName $HOSTNAME:/" /etc/httpd/conf/httpd.conf || die

    # Start Apache
    service httpd start || die

    #----------------
    # Finish up

    if [ -n "$VERBOSE" ]; then
	echo "ARMS installed"
    fi
}


#----------------------------------------------------------------
# Uninstall ARMS

function arms_uninstall () {

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
    # Remove temporary installer files

    if [ -d "$TMPDIR" ]; then
	rm -rf "$TMPDIR" || die
    fi

    if [ -n "$VERBOSE" ]; then
	echo "ARMS installer files removed"
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
    echo "Usage: $PROG [options]"
    echo "Options:"
    echo "  -i | --install     install ARMS (default action)"
    echo "  -u | --uninstall   uninstall ARMS"
    echo "  -c | --cleanup     delete temporary installer files"
    echo "  -t | --tmpdir dir  directory for installer files (default: $DEFAULT_TMPDIR)"
    echo "  -v | --verbose     print extra information during execution"
    echo "  -h | --help        show this message"
    exit 0
fi

if [ -z "$DO_INSTALL" -a -z "$DO_UNINSTALL" -a -z "$DO_CLEANUP" ]; then
    # No action explicitly specified: default to install
    DO_INSTALL=yes
fi

if [ $# -gt 0 ]; then
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
