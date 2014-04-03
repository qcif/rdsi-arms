```
title: Installation Guide using Puppet
layout: page
tags: ['intro','page']
pageOrder: 2
```
Installing ARMS using Puppet is by far the most streamlined method for installation and the easiest when you need to manage a number of environments (such as a test instance, demo instance and a production instance).

###System Requirements
Our puppet scripts have only been tested with CentOS.

###Installation Instructions

####Step 1. Fork the puppet-hiera-redbox project from GitHub
If you are managing multiple environments, you should use [Heira](http://docs.puppetlabs.com/hiera/1/) to define your environment configuration. Fork our [public repository](#) to your own private repository.

####Step 2. Configure Environment Properties
Please see [heira config guide](#) *Coming soon*

####Step 3. Install puppet on your server
Please consult the [Puppet documentation](http://docs.puppetlabs.com/guides/installation.html) for information

####Step 4. Install and Apply Puppet Heira Configuration
Please see the [README.md](#) in the Puppet Heira GitHub project for more infomation *Coming soon*

####Step 5. Install and Apply Redbox Puppet Module
Please see the [README.md](https://bitbucket.org/qcifltd/puppet-redbox/src/602e221ad18d855c2593bd74c014961f7138a658/README.md?at=master) in the Redbox Puppet Module GitHub project for more infomation *Coming soon*



