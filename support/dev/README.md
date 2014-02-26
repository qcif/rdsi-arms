# Installing ARMS manually from the Nexus repository

## Overview

These instructions describe how to manually install ARMS from the
pre-compiled releases in the Nexus repository.

There are other ways to install ARMS, such as installing it from the
sources or using Puppet to install from the Nexus repository.

## Requirements

These instructions have been tested on CentOS 6.5, but should work
with any RHEL-based distribution.

## Pre-requsites

* The server's hostname must be configured correctly.
     - Test: running the `hostname` command should produce the correct result.
     - In CentOS 6.5, edit the `/etc/sysconfig/network` file and rebooting.
     - In Fedora 20, edit the `/etc/hostname` file.

* The server's hostname must be resolvable.
     - Test: running `ping` on the hostname pings the server.
     - Either add an entry for it in the `/etc/hosts` file or configure DNS.

Note:  currently ipaddress is used for redbox and mint environments. To
not show ipaddress (if DNS setup manually) change to dns name

## Instructions

### 1. Obtain installation files

Obtain the installation files from GitHub. These commands do not have
to be run with root privileges: the files can be stored anywhere and
can be owned by any user.

In this example, they are placed in `/tmp/arms-install`:

    mkdir /tmp/arms-install
    cd /tmp/arms-install

    curl -O https://raw.github.com/qcif/rdsi-arms/master/support/dev/deploy.sh
    curl -O https://raw.github.com/qcif/rdsi-arms/master/support/dev/apache
    chmod a+x deploy.sh

   
### 2. Install Java and Apache

Note: steps 2 and onwards need to be run with root privileges. This
can be done by either prefacing every command with _sudo_.

For RHEL-based Linux distributions (e.g. CentOS), use _yum_ to install Java and Apache.

    yum install java-1.7.0-openjdk
    yum install httpd

### 3. Create the redbox user and group

Create a _redbox_ user account, as a system user (i.e. no aging
information in /etc/shadow and numeric identifiers are in the system
user range and no home directory).

    adduser --system redbox

### 4. Create directories to install services in
    
    mkdir -p /opt/mint /opt/redbox
    chown redbox:redbox /opt/mint /opt/redbox


### 5. Configure and run Apache

a. Copy the configuration for ReDBox into Apache's configuration directory.

    cp apache /etc/httpd/conf.d/25-redbox.conf

b. Set the _ServerName_ in Apache's configuration file.
Find the commented entry for _ServerName_ and change it to the fully
qualified domain name (or IP address) for the server. For example,
`ServerName arms.example.com:80`.

    vi /etc/httpd/conf/httpd.conf


c. Start Apache.

    service httpd start

Test Apache by running `service httpd status`.

### 6. Install ReDBox and Mint

    su redbox -c "./deploy.sh redbox"
    su redbox -c "./deploy.sh mint"

Check the log files (in _/opt/redbox/home/logs_ and
_/opt/mint/home/logs_) to ensure no errors were encountered.

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

Installs ReDBox or Mint from the latest version on the Nexus repository.

Checks the Nexus repository for the latest pre-compiled release and
installs it if it hasn't already been installed.

ReDBox will be installed into `/opt/redbox` and Mint will
be installed into `/opt/mint`.

It will only be installed (and downloaded if necessary) if there is no
currently installed version or the installed version is not the
latest. This can be changed with the `--reinstall` option, which
forces it to always perform an install.

If the latest installer archive has already been downloaded, it will
not be downloaded again from Nexus repository. This can be changed
with the `--download` option, which forces it to always download a new
copy of the installation archive. The downloaded installer archives
are stored in /tmp/redbox-install or /tmp/mint-install.

Extra output will be printed out if the `--verbose` option is specified.

Examples:

    ./deploy.sh redbox
    ./deploy.sh mint
    rm -r /tmp/redbox-install
    rm -r /tmp/mint-install
