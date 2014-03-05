define redbox::add_directory (
  $end_path = $title,
  $owner) {
  file { "/opt/${end_path}":
    ensure  => directory,
    recurse => true,
    owner   => $owner,
    require => Redbox::Add_systemuser[$owner],
  }
}

