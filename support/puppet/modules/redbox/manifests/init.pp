# == Class: redbox
#
# Full description of class redbox here.
#
# === Parameters
#
# Document parameters here.
#
# [*sample_parameter*]
#   Explanation of what this parameter affects and what it defaults to.
#   e.g. "Specify one or more upstream ntp servers as an array."
#
# === Variables
#
# Here you should define a list of variables that this module would require.
#
# [*sample_variable*]
#   Explanation of how this variable affects the funtion of this class and if
#   it has a default. e.g. "The parameter enc_ntp_servers must be set by the
#   External Node Classifier as a comma separated list of hostnames." (Note,
#   global variables should be avoided in favor of class parameters as
#   of Puppet 2.6.)
#
# === Examples
#
#  class { redbox:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Author Name <author@domain.com>
#
# === Copyright
#
# Copyright 2013 Your name here, unless otherwise noted.
#
## TODO : add stages.
class redbox( 
	$redbox_user = 'redbox',
	$directories = [ 'redbox', 'mint', 'deploy', ],
  	$static_files = [ 'deploy.sh', 'redbox.cron', 'redbox-mint.sh', 'start_all.sh'],
) {
 
  host { $::fqdn:
      ip => $::ipaddress,
  }  
  
  redbox_utilities::add_systemuser { $redbox_user: }
  -> 
  add_directory { $directories: 
    owner =>  $redbox_user,
  } 
  ->
  redbox_utilities::add_static_file { $static_files:
  	source 		=> "https://raw.github.com/qcif/rdsi-arms/master/support/dev",
  	destination => "/home/${redbox_user}",
    owner  		=> $redbox_user,
  }
  ->
  class { 'add_all_packages':}

}
