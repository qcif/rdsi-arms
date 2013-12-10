define redbox::add_static_file($static_file=$title, $owner) {
  $source = "wget https://raw.github.com/redbox-mint-contrib/config-samples/master/Server/$static_file"
  $destination = "/home/redbox/$static_file"

  exec {"$source  -O $destination":}
  ->
  file { $destination:
    ensure  => file,
    owner   => $owner,
    group   => $owner,
    mode    => 744,
    require => Add_systemuser[$owner],
  }
}
