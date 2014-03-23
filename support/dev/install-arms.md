# install-arms.sh

## Name

install-arms.sh - installer and uninstaller for ARMS

## Synopsis

    install-arms.sh [options] [redboxInstallArchive]

## Description

Installs and uninstalls ARMS.

`--install`
: install ARMS. Using previously downloaded installer files if
  available, otherwise downloading them.

`--uninstall`
: uninstall ARMS. If ARMS is not installed, nothing is done.

`--cleanup`
: delete installer files. If there are no installer files, nothing is done.

`--tmpdir dir`
: directory for downloaded installer files. Default is _/tmp/install-arms_.

`--verbose`
: prints extra information during execution.

`--help`
: shows a summary of options.

`redboxInstallArchive`
: the ReDBox install archive (tar.gz file) to install. If this is not
  provided, then the latest install archive from the Nexus repository
  will be used. Note: this file will be accessed by the _deploy.sh_
  script running as the _redbox_ user, so it (and the directory it is in)
  must be readable by the _redbox_ user.

Note: this script **must** be run with root privileges.

The Mint installer is always obtained from the Nexus repository; there
is no way to explicitly specify a Mint install archive.


## Examples

To install ARMS (using previously downloaded installer files or
downloading them if they are not present):

    sudo ./install-arms.sh --install

To uninstall ARMS (but keep any downloaded installer files) -- this
works even if ARMS is not installed:

    sudo ./install-arms.sh --uninstall

To delete any downloaded installer files -- this works even if there
are no downloaded installer files:

    sudo ./install-arms.sh --cleanup

To reinstall ARMS (using previously downloaded installer files or
downloading them if they are not present):

    sudo ./install-arms.sh --uninstall --install

To remove all trace of ARMS (i.e. uninstall it and removing any
installer files):

    sudo ./install-arms.sh --cleanup --uninstall

To perform a fresh reinstall (not using any previously downloaded
installer files, but re-downloading them):

    sudo ./install-arms.sh --cleanup --uninstall --install

Note: the combination of just `--cleanup` and `--install` is not
recommended. It will work if ARMS is not installed (performing the
same action as a cleanup and then install), but it will fail if it is
already installed.

To install ARMS using a particular ReDBox install archive, instead
of using a pre-built one from the Nexus repository:

    sudo ./install-arms.sh my-redbox-installer.tar.gz


## Internal behaviour

### Installation

During installation, it performs the following tasks:

- Obtain the two installation files _deploy.sh_ and the
  _apache-arms.conf_. If available, these are copied from the same
  directory as the _install-arms.sh_ script; otherwise they are
  downloaded from GitHub. They are both placed in _/tmp/install-arms_.

- Installing Java (using yum).

- Installing Apache (using yum).

- Create the "redbox" user account and group.

- Create the installation directory for Mint: _/opt/mint_.

- Use the _deploy.sh_ script to install Mint. If the tar.gz has not
  been cached from a previous install, it will be downloaded from the
  QCIF Nexus repository and saved to _/tmp/install-arms/install-mint_.

- Wait for Mint to start running.

- Loading Mint with the Australian and New Zealand Standard Research
  Classification (ANZSRC) Field of Research (FoR) codes
  Note: the harvester must be run from the _/opt/mint/server_ directory
  or it will not work properly.

- Create the installation directory for ReDBox: _/opt/redbox_.

- Use the _deploy.sh_ script to install ReDBox. If a
  redboxInstallArchive has been supplied, it will use a copy of
  it. Otherwise, if the tar.gz has not been cached from a previous
  install, it will be downloaded from the QCIF Nexus repository and
  saved to _/tmp/install-arms/install-redbox_.

- Wait for ReDBox to start running.

- Configuring Apache by copying the _apache-arms.conf_ config file
  into _/etc/httpd/conf.d_.

- Sets the _ServerName_ in Apache's configuration file.
  Find the commented entry for _ServerName_ and change it to the fully
  qualified domain name (or IP address) for the server. For example,
  `ServerName arms.example.com:80`.

- Start Apache.

- Prime Mint by visiting one of its URLs.
  This prevents timeout errors when ReDBox first queries Mint (i.e.
  when it brings up the first form requiring FoR codes).

- Prime ReDBox by visiting one of its URLs.
  This makes the first request from a user respond more quicker.

### Uninstall

During uninstall, it performs the following tasks:

- Stop Apache.
- Unconfigure ARMS from Apache by deleting the apache-arms.conf file and undo the edit.

- Stop ReDBox.
- Uninstall ReDBox by deleting /opt/redbox.

- Stop Mint.
- Uninstall Mint by deleting /opt/mint.

### Cleanup

During cleanup, it performs the following tasks:

- Deletes /tmp/install-arms.


## Files and directories

ReDBox is installed to _/opt/redbox_.

Mint is installed to _/opt/mint_.

Installer files are cached in _/tmp/install-arms_.

## See also

* Documentation for [deploy.sh](deploy.md) the ARMS-ReDBox and Mint installer which this script invokes.

* [Deploying ARMS](../../doc/deployment.md)
