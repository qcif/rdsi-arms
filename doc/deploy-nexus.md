# Deploying ARMS from Nexus

## Overview

This page describes how to install ARMS from the pre-built components
on QCIF's Nexus repository. It downloads ARMS ReDBox and Mint from the
QCIF Nexus repository and installs them. It installs and configures
the Apache HTTP server from the distribution package manager.

## Requirements

- A server machine running Linux or Unix.

    These instructions have been tested on CentOS 6.5 and Fedora 20.
    They might need to be modified to work with other versions,
    other distributions of Linux and other operating systems.

- Root privileges on the server machine. Either an account with _sudo_
  privileges or access to the root account.

- tar

        sudo yum -y install tar

## Procedure

### Step 1. Obtain the _install-arms.sh_ script

This can be found in the `support/dev` directory of the sources, or it
can be downloaded from GitHub using:

    curl -O https://raw.github.com/qcif/rdsi-arms/master/support/dev/install-arms.sh
    chmod a+x ./install-arms.sh 

### Step 2. Install

Run the installer script.

    sudo ./install-arms.sh --verbose

Note: this can take a few minutes to run, if it needs to download
files from GitHub and/or the Nexus repository.

## Troubleshooting

### Cannot resolve this server's hostname

The _install-arms.sh_ script will configure Apache with the local
hostname. This requires the localhost name to be set up correctly: the
value obtained from `hostname` should be resolvable from the server.

    hostname
    ping -c 4 `hostname`

How it is configured will depend on your operating system and
distribution. For example, in some Linux distributions edit the
`/etc/sysconfig/network` file and reboot, or edit the `/etc/hostname`
file.

Configure DNS or add an entry for it in the server's `/etc/hosts` file.

### Uninstalling ARMS

To uninstall ARMS:

    $ sudo ./install-arms.sh --uninstall

Note: Java and Apache will not be uninstalled, and the "redbox" user
account will not be removed.

### Remove cached installation files

The temporary files are reused when reinstalling. To force them to be
downloaded in subsequent installs, or to just remove them:

    $ sudo ./install-arms.sh --cleanup


## See also

- Documentation for [install-arms.sh](../support/dev/install-arms.md).
- Other methods for [deploying ARMS](deployment.md).

