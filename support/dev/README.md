# Unsupported deployment scripts

## Overview

This directory contains **unsupported** scripts and files for deploying ARMS.

The officially supported deployment method is to use Puppet. The scripts
in this directory are used for internal testing and are not supported.

The scripts implement two ways to deploy ARMS:

- [Deploy pre-built components from the  Nexus repository](INSTALL-nexus.md)
- [Build from source code and then deploy](INSTALL-source.md)

## Contents

- [arms-deploy.sh](arms-deploy.md) - setup environment, download sources from GitHub, builds and installs ARMS
- [install-arms.sh](install-arms.md) - installs ARMS
- [deploy.sh](deploy.md) - deploys either Mint or ARMS-ReDBox
- apache-arms.conf - Apache configuration file

## See also

- Documentation on how these scripts can be used can be found in the
  [ARMS deployment](../../doc/deployment.md) documentation.
