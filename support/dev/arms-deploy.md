# arms-deploy.sh

## Name

arms-deploy.sh - deployer and remover for ARMS

## Synopsis

    arms-deploy.sh [options] [srcdir]

## Description

Deploy or removes ARMS.

This script was written to make it easy to start with a totally new
instance of the operating system and to build a new deployment of ARMS
for testing.

When deploying, this script does everything: making the hostname
resolvable; installing Git, Java and Maven; downloading ARMS sources
from GitHub; building it; and installing it (i.e. Mint, ARMS-ReDBox
and Apache).

The default action, if neither `--deploy` or `--remove` is specified,
is to show the status of the ARMS deployment. If both `--deploy` and
`--remove` are specified, ARMS is first removed and the re-deployed.

`--deploy`
: deploy ARMS.

`--remove`
: remove ARMS. If ARMS is not deployed, nothing is done.

`--verbose`
: prints extra information during execution.

`--help`
: shows a summary of options.

`srcdir`
: directory to download sources into. Defaults to a directory called "arms".

Note: this user **must** have sudo privileges to use this script.

## Examples

To deploy ARMS:

    ./arms-deploy.sh --deploy

To remove ARMS:

    ./arms-deploy.sh --remove

To show the status of ARMS deployment:

    ./arms-deploy.sh --verbose

## Limitations

Only works for RHEL-based operating systems (e.g. Fedora and CentOS)
that use the _yum_ package manager.

## See also

* Documentation for [install-arms.sh](install-arms.md)

* [Deploying ARMS](../../doc/deployment.md)
