define redbox::update_server_url (
  $system     = $title,
  $has_ssl    = false,
  $server_url = $::fqdn,
  $install_parent_directory) {
  if ($has_ssl) {
    $protocol = https
  } else {
    $protocol = http
  }

  file_line { "update_server_url_${system}":
    path  => "${install_parent_directory}/${system}/server/tf_env.sh",
    line  => "SERVER_URL=${protocol}://${server_url}/",
    match => "^.*SERVER_URL=.*$",
  }

}
