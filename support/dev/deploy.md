# deploy.sh

## Name

deploy.sh - installer for ARMS-ReDBox or Mint

## Synopsis

    deploy.sh [options] (redbox | mint) [installArchive]

## Description

Installs ReDBox or Mint.

`--reinstall`
: forces reinstall, even if installed version is up to date.

`--download`
: forces download from Nexus, even if latest version is already downloaded.

`--tmpdir dir`
: directory for downloaded installer files. Default is
  _/tmp/install-redbox_ or _/tmp/install-mint_.

`--verbose`
: prints extra information during execution.

`--help`
: shows a summary of options.

`installArchive`
: the install archive (tar.gz file) to install. If this is not provided,
  then the latest install archive from the Nexus repository will be used.

Note: this script **must** be run as the user that will be running the
ReDBox and Mint processes (i.e. as the "redbox" user).

The installation directory (_/opt/redbox_ or _/opt/mint_) **must** be
created first and given the correct permissions for the user to write
to (since _/opt_ cannot be written to by this user).


## Behaviour

Checks the Nexus repository for the latest pre-compiled release and
installs it if it hasn't already been installed.

It will only be installed (and downloaded if necessary) if there is no
currently installed version or the installed version is not the
latest. This can be changed with the `--reinstall` option, which
forces it to always perform an install.

If the latest install file has already been downloaded, it will
not be downloaded again from Nexus repository. This can be changed
with the `--download` option, which forces it to always download a new
copy of the install file.


## Examples

Install the ARMS version of ReDBox:

    ./deploy.sh redbox

Install Mint:

    ./deploy.sh mint

Remove temporary installer files:

    rm -r /tmp/redbox-install
    rm -r /tmp/mint-install

Installs the supplied install archive. This is useful for testing
builds without needing to upload them to the Nexus repository.

    ./deploy.sh redbox my-test-redbox.tar.gz


## Known bugs

This script must be run as the "redbox" user. So in practice it is
usually run as:

    sudo su redbox -c "./deploy.sh ..."


## Files and directories

ReDBox is installed to _/opt/redbox_ and Mint is installed to _/opt/mint_.


## See also

* Documentation for ReDBox.
