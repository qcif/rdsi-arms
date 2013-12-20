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
class redbox {

  include variables::defaults

  Exec { 
    path => $variables::defaults::exec_path, 
    logoutput => true,
  }
 
  host { $::hostname:
      ip => '127.0.0.1',
      host_aliases => ["localhost.localdomain",  "localhost"], 
  }
 
  add_systemuser { $variables::defaults::redbox_user: }
  -> 
  add_directory { $variables::defaults::directories: 
    owner =>  $variables::defaults::redbox_user,
  } 
  ->
  add_static_file { $variables::defaults::static_files:
    owner => $variables::defaults::redbox_user,
  }
  ->
  class { 'add_all_packages':
    package_type => $variables::defaults::package_type 
  }

}
