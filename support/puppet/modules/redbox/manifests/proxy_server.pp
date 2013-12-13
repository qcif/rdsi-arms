class redbox::proxy_server {
  
  include redbox::variables::apache

  class { 'apache':
    default_mods => false,
  }
  
  apache::mod { $variables::apache::proxy_http: }
  
  apache::vhost { $::ipaddress:
    docroot    => $variables::apache::docroot,
    port       => $variables::apache::port,
    proxy_pass => $variables::apache::proxy_pass,
  }

}

