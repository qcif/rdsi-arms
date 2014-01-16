class redbox::variables::apache {

  $enabled_mods = [ 'proxy_http', ]

  $proxy_pass = [
    { 'path' => '/redbox',
      'url'  => 'http://${variables::defaults::server_id}:${variables::defaults:port}/redbox' },
    { 'path' => '/mint',
      'url'  => 'http://${variables::defaults::server_id}:9001/mint' }
  ]

  $docroot = '/var/www/html'
  $port = '80'
  $ap = 'apache'
}
