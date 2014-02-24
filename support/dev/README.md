# Deployment instructions

## Overview

These instructions and scripts describe how to install the system
without using Puppet.

## Requirements

These instructions have been tested on CentOS 6.5, but should work
with any RHEL-based distribution.

## Pre-requsites

* Ensure you add the IP address and hostname to /etc/hosts
* Once httpd installed, update "ServerName" in httpd/conf/httpd.conf to your fqdn or ip address
* Consider also updating hostname of box (/etc/sysconfig/network and /etc/hosts)
* currently ipaddress is used for redbox and mint environments. To not show ipaddress (if DNS setup manually) change to dns name

## Instructions

The following instructions should be run with root privileges. This
can be done from an account with sudo privileges, by either prefacing
every command with _sudo_ or in a root shell started using `sudo -s`).

### Install Java and Apache

For RHEL-based Linux distributions (e.g. CentOS), use _yum_ to install Java and Apache.

    yum install java-1.7.0-openjdk
    yum install httpd

### Create the redbox user and group

Create a _redbox_ user account, as a system user (i.e. no aging
information in /etc/shadow and numeric identifiers are in the system
user range) and with a home directory.

    adduser --system -m redbox

### Create directories to install services in
    
    mkdir -p /opt/mint /opt/redbox /opt/deploy
    chown redbox:redbox /opt/mint /opt/redbox /opt/deploy

### Obtain installation files

    cd /opt/deploy

    # The following commands are run as the redbox user in its home directory

    curl -O https://raw.github.com/qcif/rdsi-arms/master/support/dev/deploy.sh
    curl -O https://raw.github.com/qcif/rdsi-arms/master/support/dev/start_all.sh
    curl -O https://raw.github.com/qcif/rdsi-arms/master/support/dev/redbox.cron
    curl -O https://raw.github.com/qcif/rdsi-arms/master/support/dev/redbox-mint.sh
    curl -O https://raw.github.com/qcif/rdsi-arms/master/support/dev/apache
    chmod a+x *.sh
    

### Add ReDBox to Apache

Copy the configuration for ReDBox into Apache's configuration directory.

    cp apache /etc/httpd/conf.d/25-redbox.conf

### Start Apache

    service httpd start

### Install ReDBox and Mint

    su redbox -c "./deploy.sh redbox"
    su redbox -c "./deploy.sh mint"

### Build Mint indexes

    cd /opt/mint/server
    sudo -u redbox ./tf_harvest.sh ANZSRC_FOR


##Scripts
* redbox.cron - a crontab file
* start_all.sh - initial startup of deploy.sh for redbox and mint, before cron is used.
* apache - the apache config
* redbox-mint.sh - a /etc/init.d/ script
* deploy.sh - takes 1 param (redbox | mint) and checks to see if there's a new deployment