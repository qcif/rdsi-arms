# Deploying ARMS from sources

## Overview

This page describes how to build an ARMS ReDBox from the sources. It
also describes how to install it, Mint obtained from QCIF's Nexus
repository, and the Apache HTTP server, to produce a running
deployment of ARMS.

## Requirements

- A server machine running Linux or Unix.

    These instructions have been tested on CentOS 6.5 and Fedora 20.
    They might need to be modified to work with other versions,
    other distributions of Linux and other operating systems.

- Root privileges on the server machine. Either an account with _sudo_
  privileges or access to the root account.

- tar

        sudo yum -y install tar

- Git

        sudo yum -y install git

- Java

        sudo yum -y install java-1.7.0-openjdk
        echo 'export JAVA_HOME=/usr/lib/jvm/jre' >> ~/.bash_profile
        . ~/.bash_profile

- Maven 2.2.1

    Caution: newer versions of Maven will run, but the resulting
    installer will not work. This is a known issue.

        curl -s -O http://archive.apache.org/dist/maven/binaries/apache-maven-2.2.1-bin.tar.gz
        tar xfz apache-maven-2.2.1-bin.tar.gz
        rm apache-maven-2.2.1-bin.tar.gz 
        sudo mv apache-maven-2.2.1 /opt/maven
        echo 'PATH=$PATH:/opt/maven/bin' >> ~/.bash_profile 
        . ~/.bash_profile

## Procedure

### Step 1. Obtain the sources

Create a subdirectory for building the ARMS ReDBox and obtain a copy
of the sources from GitHub.

    mkdir arms  # or some other directory name
    cd arms
    git clone https://github.com/qcif/rdsi-arms.git

Note: it is recommended that this extra directory be created, because the
build process creates additional directories in the parent directory.

### Step 2. Build

Build the ARMS ReDBox with the "dev" profile. This profile configures
ARMS to use local username and passwords for authentication, which is
useful for testing.

    cd rdsi-arms
    mvn clean package -Pbuild-package,dev

The build process will create a _tar.gz_ file in the _target_
directory. That is the ARMS ReDBox installer.

### Step 3. Install

Install the ARMS ReDBox, Mint from QCIF's Nexus repository and the Apache HTTP server using the _install_arms.sh_ script:

    sudo support/dev/install-arms.sh -v target/redbox-rdsi-arms-*.tar.gz

The ARMS ReDBox is installed in `/opt/redbox` and Mint is installed in
`/opt/mint`.

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
