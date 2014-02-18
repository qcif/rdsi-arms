# == Class: redbox_shibboleth
#
# Full description of class redbox_shibboleth here.
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
#  class { redbox_shibboleth:
#    servers => [ 'pool.ntp.org', 'ntp.local.company.com' ],
#  }
#
# === Authors
#
# Matt Mulholland <matt@redboxresearchdata.com.au>
#
# === Copyright
#
# Copyright (C) 2011-2012 Queensland Cyber Infrastructure Foundation (http://www.qcif.edu.au/)
#
class redbox_shibboleth(
  $static_file = "go-redhat",
  $base_url = "https://raw.github.com/ausaccessfed/aasc/master",
  $working_dir = "/home/redbox",
) {
 
  class { 'redbox_apache::proxy_server':
     is_shibboleth_active => true,
  }
  ->
  redbox_utilities::add_static_file { $static_file:
    owner  		 => 'root',
    source 		 => $base_url,
  	destination => $working_dir,
  }
  ->
  class { 'execute_script':
    path => "${working_dir}/${static_file}",
  }
  
}

