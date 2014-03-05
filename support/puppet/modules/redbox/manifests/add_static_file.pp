define redbox::add_static_file (
  $static_file        = $title,
  $owner,
  $options            = '',
  $source,
  $destination,
  $is_source_complete = false,) {
  if ($is_source_complete) {
    $full_source = $source
  } else {
    $full_source = "${source}/${static_file}"
  }

  exec { "wget $options \"$full_source\"  -O ${destination}/${static_file}": logoutput => true, } ->
  file { "${destination}/${static_file}":
    ensure => file,
    owner  => $owner,
    group  => $owner,
    mode   => 744,
  }
}
