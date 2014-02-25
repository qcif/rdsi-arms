# Installing ARMS from Maven manually

## Overview

These instructions describe how to manually install ARMS from the
pre-compiled releases in Maven.

There are other ways to install ARMS, such as installing it from the
sources and using Puppet to install the pre-compiled releases in
Maven.

## Requirements

These instructions have been tested on CentOS 6.5, but should work
with any RHEL-based distribution.

## Pre-requsites

* Ensure you add the IP address and hostname to /etc/hosts
* Consider also updating hostname of box (/etc/sysconfig/network and /etc/hosts)
* currently ipaddress is used for redbox and mint environments. To not show ipaddress (if DNS setup manually) change to dns name

## Instructions

The following instructions should be run with root privileges. This
can be done from an account with sudo privileges, by either prefacing
every command with _sudo_ or in a root shell started using `sudo -s`).

### 1. Install Java and Apache

For RHEL-based Linux distributions (e.g. CentOS), use _yum_ to install Java and Apache.

    yum install java-1.7.0-openjdk
    yum install httpd

### 2. Create the redbox user and group

Create a _redbox_ user account, as a system user (i.e. no aging
information in /etc/shadow and numeric identifiers are in the system
user range and no home directory).

    adduser --system redbox

### 3. Create directories to install services in
    
    mkdir -p /opt/mint /opt/redbox
    chown redbox:redbox /opt/mint /opt/redbox

### 4. Obtain installation files

Obtain the installation files from GitHub. These commands do not have
to be run with root privileges: the files can be stored anywhere and
can be owned by any user.

    mkdir /tmp/arms-install
    cd /tmp/arms-install

    curl -O https://raw.github.com/qcif/rdsi-arms/master/support/dev/deploy.sh
    curl -O https://raw.github.com/qcif/rdsi-arms/master/support/dev/apache
    #curl -O https://raw.github.com/qcif/rdsi-arms/master/support/dev/start_all.sh
    #curl -O https://raw.github.com/qcif/rdsi-arms/master/support/dev/redbox.cron
    #curl -O https://raw.github.com/qcif/rdsi-arms/master/support/dev/redbox-mint.sh
    chmod a+x *.sh
    

### 5. Configure and run Apache

Copy the configuration for ReDBox into Apache's configuration directory.

    cp apache /etc/httpd/conf.d/25-redbox.conf

Set the `ServerName` in the HTTPD configuration file to the host's FQDN or IP address.

    vi /etc/httpd/conf/httpd.conf

Start Apache.

    service httpd start

### 6. Install ReDBox and Mint

    su redbox -c "./deploy.sh redbox"
    su redbox -c "./deploy.sh mint"

Check the log files to ensure no errors were encountered.

### 7. Build Mint indexes

    cd /opt/mint/server
    sudo -u redbox ./tf_harvest.sh ANZSRC_FOR


## Scripts

* redbox.cron - a crontab file
* start_all.sh - initial startup of deploy.sh for redbox and mint, before cron is used.
* apache - the apache config
* redbox-mint.sh - a /etc/init.d/ script
* deploy.sh - takes 1 param (redbox | mint) and checks to see if there's a new deployment

### deploy.sh

Installs ReDBox or Mint from the latest version on the Maven Nexus server.

Checks the Maven Nexus server for the latest pre-compiled release and
installs it if it hasn't already been installed.

By default, ReDBox will be installed into `/opt/redbox` and Mint will
be installed into `/opt/mint`. This can be changed with the
`--installdir` option.

It will only be installed (and downloaded if necessary) if there is no
currently installed version or the installed version is not the
latest. This can be changed with the `--reinstall` option, which
forces it to always perform an install.

If the latest installer archive has already been downloaded, it will
not be downloaded again from Maven Nexus. This can be changed with the
`--download` option, which forces it to always download a new copy of
the installation archive. The downloaded installer archives are stored
in /tmp/redbox-install or /tmp/mint-install.

Extra output will be printed out if the `--verbose` option is specified.

Examples:

    ./deploy.sh redbox
    ./deploy.sh mint
    rm -r /tmp/redbox-install
    rm -r /tmp/mint-install
