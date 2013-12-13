class redbox::variables::apache {

  $enabled_mods = [ 'proxy_http', ]

  $proxy_pass = [
    { 'path' => '/redbox',
      'url'  => 'http://localhost:9000/redbox' },
    { 'path' => '/mint',
      'url'  => 'http://localhost:9001/mint' }
  ]

  $docroot = '/var/www/html'
  $port = '80'
  $ap = 'apache'
}
