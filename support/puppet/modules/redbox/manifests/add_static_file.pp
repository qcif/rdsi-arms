define redbox::add_static_file(
	$static_file=$title, 
	$owner,
	$options='',
	$source,
	$destination,
) {
  
  exec {"wget $options ${source}/${static_file}  -O ${destination}/${static_file}":}
  ->
  file { "${destination}/${static_file}":
    ensure  => file,
    owner   => $owner,
    group   => $owner,
    mode    => 744,
  }
}
