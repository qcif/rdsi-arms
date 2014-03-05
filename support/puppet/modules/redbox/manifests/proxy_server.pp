class redbox::proxy_server (
  $priority       = '25',
  $mint_port      = '9001',
  $server_url     = $::fqdn,
  $docroot        = '/var/www/html',
  $proxy          = undef,
  $shibboleth_env = undef,
  $ssl_files      = undef,) {
  case $operatingsystem {
    'centos', 'redhat', 'fedora' : {
      $conf_dir    = '/etc/httpd/conf.d'
      $log_dir     = '/etc/httpd/logs'
      $apache_conf = '/etc/httpd/conf/httpd.conf'
    }
    'default'                    : {
      $conf_dir    = '/etc/apache2/sites-enabled'
      $log_dir     = '/var/log/apache2'
      $apache_conf = '/etc/apache2/apache2.conf'
    }
  }

  class { 'apache':
    default_mods        => false,
    default_confd_files => false,
    default_vhost       => false,
    servername          => $server_url,
  } ->
  # # disabling defaults in apache causes Listen 80 to be commented out - uncomment.
  file_line { 'listen_80':
    path  => "$apache_conf",
    line  => "Listen 80",
    match => ".*Listen[[:space:]]+80[[:space:]]*?$",
  }

  include apache::mod::proxy
  include apache::mod::proxy_http
  include apache::mod::proxy_ajp

  if ($shibboleth_env) {
    class { 'redbox::shibboleth':
      shibboleth_env => $shibboleth_env,
      require        => Class['apache'],
      before         => File['redbox.conf'],
    }
    $redbox_path = "ajp://localhost:8009/"
  }

  file { 'redbox.conf':
    path    => "${conf_dir}/${priority}-redbox.conf",
    ensure  => file,
    content => template("redbox/redbox.conf.erb"),
    require => Class['apache'],
    notify  => Service['httpd'],
  }

  if ($ssl_files) {
    file { [values($ssl_files)]: ensure => file, } ->
    apache::vhost { 'redbox-ssl':
      port       => '443',
      docroot    => $docroot,
      ssl        => true,
      ssl_cert   => "${ssl_files[cert]}",
      ssl_key    => "${ssl_files[key]}",
      ssl_chain  => "${ssl_files[chain]}",
      proxy_pass => $proxy,
      servername => $server_url
    }
  }
}
