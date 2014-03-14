define redbox::add_redbox_package (
  $packages         = $title,
  $owner            = 'redbox',
  $install_parent_directory,
  $server_directory = 'server',
  $has_ssl          = false,
  $server_url       = $::fqdn,) {
  $redbox_package = $packages[package]
  $redbox_system  = $packages[system]
  $target_path    = "${install_parent_directory}/${redbox_system}/${server_directory}"

  package { $redbox_package: } ->
  redbox::update_server_url { $redbox_system:
    has_ssl                  => $has_ssl,
    server_url               => $server_url,
    install_parent_directory => $install_parent_directory,
  } ->
  exec { "service ${redbox_system} restart":
    tries       => 3,
    timeout     => 20,
    try_sleep   => 3,
    user        => 'root',
    refreshonly => true,
    subscribe   => Package[$redbox_package],
  } ->
  exec { "${target_path}/tf.sh restart":
    tries     => 2,
    timeout   => 2,
    try_sleep => 3,
    user      => $owner,
    creates   => "${target_path}/tf.pid"
  }

  # problem possibly with chkconfig not picked up by puppet - so use exec
  # service { 'redbox':
  #  enable => true,
  #  ensure => running,
  #}
}