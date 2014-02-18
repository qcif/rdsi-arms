class redbox::proxy_server(
  $priority = '25',
  $mint_port = '9001',
  $server_id = $::fqdn,
  $docroot = '/var/www/html',
  $redbox_path = "ajp://localhost:8009/",
  $mint_path = "http://localhost:9001/mint/",
  $is_shibboleth_active = false,
  ) {
    
  case $operatingsystem {
    'centos', 'redhat', 'fedora': { $conf_dir   = '/etc/httpd/conf.d'
                                    $log_dir = '/var/log/httpd'}
    'ubuntu', 'debian':           { $conf_dir   = '/etc/apache2/sites-enabled'
                                    $log_dir = '/var/log/apache2'}
    default:                     { $conf_dir   = '/etc/apache2/sites-enabled'
                                    $log_dir = '/var/log/apache2'}
  }

  class { 'apache':
    default_mods        => false,
    default_confd_files => false,
  }
  
  include apache::mod::proxy
  include apache::mod::proxy_http
  include apache::mod::proxy_ajp
  
  file { 'redbox.conf':
    path    => "${conf_dir}/${priority}_redbox.conf",
    ensure  => file,
    content => template("redbox/redbox.conf.erb"),
  }

}

