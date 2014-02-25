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
  will be used. Note: the Mint installer is always obtained from the
  Nexus repository; there is no way to explicitly specify a Mint
  install archive.

Note: this script **must** be run with root privileges.

### Behaviour

This script automates the process of installing ARMS. It performs the
following tasks:

- Installing Java and Apache
- Creating a user account to run ReDBox and Mint
- Installing and running Mint
- Loading Mint with the Australian and New Zealand Standard Research
  Classification (ANZSRC) Field of Research (FoR) codes
- Installing and running the ARMS customised version of ReDBox
- Configuring Apache to work with ReDBox and Mint

This script can also be used to uninstall ARMS.

The installation process can download the necessary installer
files. These are kept for subsequent reuse, if ARMS is to be
reinstalled. This script can also clean up by deleting those installer
files.


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


## Files and directories

ReDBox is installed to _/opt/redbox_ and Mint is installed to _/opt/mint_.


## See also

* Documentation for deploy.sh, the ARMS-ReDBox and Mint installer.

