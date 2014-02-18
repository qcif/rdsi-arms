define redbox_utilities::add_static_file(
	$static_file=$title, 
	$owner,
	$options='',
	$source,
	$destination,
	$exec_path = [
      '/usr/local/bin',
      '/opt/local/bin',
      '/usr/bin',
      '/usr/sbin',
      '/bin',
      '/sbin'],
) {
  
  Exec {
    path => $exec_path,
    logoutput => false,
  }
  
  exec {"wget $options ${source}/${static_file}  -O ${destination}/${static_file}":}
  ->
  file { "${destination}/${static_file}":
    ensure  => file,
    owner   => $owner,
    group   => $owner,
    mode    => 744,
  }
}
