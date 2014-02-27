# Installing ARMS

## Overview

These instructions describe how to install ARMS from the pre-built
releases in the Nexus repository.


## Requirements

- A server machine running Linux or Unix.

    These instructions have been tested on CentOS 6.5 and Fedora 20.
    They might need to be modified to work with other versions, other
    distributions of Linux and other operating systems.

    These instructions have been designed to install ARMS from scratch
    on a new server, but can also be used to uninstall and reinstall
    ARMS.

- Root privileges on the server machine. Either an account with _sudo_
  privileges or access to the root account.

- The _install-arms.sh_ script, which can be downloaded from GitHub
  using the following commands:

        $ curl -O https://raw.github.com/qcif/rdsi-arms/master/support/dev/install-arms.sh
        $ chmod a+x install-arms.sh


## Installing ARMS

### 1. Check host is configured properly

#### The server's hostname must be configured correctly

    $ hostname

How it is configured will depend on your operating system and
distribution.  For example, in some Linux distributions edit the
`/etc/sysconfig/network` file and reboot, or edit the `/etc/hostname`
file.

#### The server's hostname must be resolvable

    $ ping -c 4 `hostname`

Configure DNS or add an entry for it in the server's `/etc/hosts` file.

### 2. Install ARMS

Installing and running ARMS involves:

- Installing Java and Apache
- Creating a user account to run ReDBox and Mint
- Installing and running Mint
- Loading Mint with the Australian and New Zealand Standard Research
  Classification (ANZSRC) Field of Research (FoR) codes
- Installing and running the ARMS customised version of ReDBox
- Configuring Apache to work with ReDBox and Mint

All these steps, including downloading the necessary files, have been
put into the ARMS install script. Run the install script with root
privileges:

    $ sudo ./install-arms.sh --verbose

Note: this can take a few minutes to run, if it needs to download
files from GitHub and/or the Nexus repository.

### 3. Testing

Open a Web browser and connect to the server machine.

### 4. (Optional) Remove installation files

Delete the temporary installation files.

    $ sudo ./install-arms.sh --cleanup

This step is optional. The temporary files can be reused if
reinstalling.


## Uninstalling ARMS

To uninstall ARMS:

    $ sudo ./install-arms.sh --uninstall

Note: Java and Apache will not be uninstalled, and the "redbox" user
account will not be removed.


## See also

- [Documentation for install-arms.sh](install-arms.md).
