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
# Matt Mulholland <matt@redboxresearchdata.com.au>
#
# === Copyright
#
# Copyright 2013 Your name here, unless otherwise noted.
#
class redbox (
  $redbox_user              = 'redbox',
  $directories              = [
    'redbox',
    'mint',
    'deploy',
    'deploy/mint'],
  $install_parent_directory = '/opt',
  $has_dns                  = true,
  $packages                 = [{
      system  => 'redbox',
      package => 'redbox-rdsi-arms-qcif',
    }
    ],
  $archives                 = [{
      name        => 'mint',
      group       => 'com.googlecode.redbox-mint',
      artifact    => 'mint-local-curation-demo',
      web_context => 'mint',
      version     => '1.6.2',
      classifier  => 'build',
      repo        => 'releases',
    }
    ],
  $proxy                    = [{
      'path' => '/',
      'url'  => 'http://localhost:9000/',
    }
    ],
  $has_ssl                  = true,
  $ssl_files                = {
    cert  => "/etc/ssl/local_certs/SSLCertificateFile/${::fqdn}.crt",
    key   => "/etc/ssl/local_certs/SSLCertificateKeyFile/${::fqdn}.key",
    chain => "/etc/ssl/local_certs/SSLCertificateChainFile/${::fqdn}_CA.crt",
  }
  ,
  $exec_path                = [
    '/usr/local/bin',
    '/opt/local/bin',
    '/usr/bin',
    '/usr/sbin',
    '/bin',
    '/sbin'],) {
  if ($has_dns and $::fqdn) {
    $server_url = $::fqdn
  } elsif ($::ipaddress) {
    $server_url = $::ipaddress
  } else {
    $server_url = $::ipaddress_lo
  }

  host { [$::fqdn]: ip => $::ipaddress, }

  Exec {
    path      => $exec_path,
    logoutput => false,
  }

  redbox::add_systemuser { $redbox_user: } ->
  add_directory { $directories:
    owner            => $redbox_user,
    parent_directory => $install_parent_directory,
  } ->
  class { 'redbox::java': }

  if ($proxy) {
    class { 'redbox::proxy_server':
      require    => Class['Redbox::Java'],
      before     => [
        Redbox::Add_redbox_package[$packages],
        Class['redbox::deploy_script']],
      server_url => $server_url,
      has_ssl    => $has_ssl,
      ssl_files  => $ssl_files,
      proxy      => $proxy,
    } ~> Service['httpd']
  }

  class { 'redbox::deploy_script':
    archives                 => $archives,
    has_ssl                  => $has_ssl,
    server_url               => $server_url,
    install_parent_directory => $install_parent_directory,
    owner                    => $redbox_user,
  }

  yumrepo { 'redbox':
    descr    => 'Redbox_repo',
    baseurl  => 'http://dev.redboxresearchdata.com.au/yum/snapshots',
    gpgcheck => 0,
    enabled  => 1,
  } ->
  exec { 'yum clean all': } ->
  redbox::add_redbox_package { $packages:
    owner                    => $redbox_user,
    install_parent_directory => $install_parent_directory,
    has_ssl                  => $has_ssl,
    server_url               => $server_url,
  }
}