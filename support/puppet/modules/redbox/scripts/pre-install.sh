#!/bin/sh

usage() {
	if [ `whoami` != 'root' ]; 
		then echo "this script must be executed as root" && exit 1;
	fi
}
usage
echo "Ensure you have copied the redbox module to /tmp."

rpm -ivh http://yum.puppetlabs.com/el/6/products/x86_64/puppetlabs-release-6-7.noarch.rpm
yum install puppet
puppet module install puppetlabs/concat
puppet module install puppetlabs/stdlib
puppet module install puppetlabs/apache

## copy redbox module to home directory
cp -Rf /tmp/redbox /usr/share/puppet/modules/
