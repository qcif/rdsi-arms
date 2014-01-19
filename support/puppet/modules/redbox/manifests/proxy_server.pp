class redbox::proxy_server {
  
  include redbox::variables::apache

  class { 'apache':
    default_mods => false,
  }
  
  apache::mod { $variables::apache::proxy_http: }

  apache::vhost { 'redbox':
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

