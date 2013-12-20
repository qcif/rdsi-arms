class redbox::proxy_server {
  
  include redbox::variables::apache

  class { 'apache':
    default_mods => false,
  }
  
  apache::mod { $variables::apache::proxy_http: }
 
  $redbox_path = "http://localhost:${variables::defaults::port}/${variables::defaults::web_path}"

  apache::vhost { $::ipaddress:
    docroot    => $variables::apache::docroot,
    port       => $variables::apache::port,
    proxy_pass => $variables::apache::proxy_pass,
  }
  ->
  file { 'index.html':
    path    => "${variables::apache::docroot}/index.html",
    ensure  => file,
    content => template("redbox/index.html.erb"),
  }

}

