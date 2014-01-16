class redbox::variables::apache {

  $enabled_mods = [ 'proxy_http', ]

  $redbox_path = "http://${variables::defaults::server_id}:${variables::defaults::port}/${variables::defaults::web_path}"
  $mint_path = "http://${variables::defaults::server_id}:9001/mint"

  $proxy_pass = [
    { 'path' => '/redbox',
      'url'  => $redbox_path },
    { 'path' => '/mint',
      'url'  => $mint_path }
  ]

  $docroot = '/var/www/html'
  $port = '80'
}
