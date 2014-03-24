define redbox::add_redbox_package (
  $packages         = $title,
  $owner            = undef,
  $install_parent_directory,
  $server_directory = 'server',
  $has_ssl          = undef,
  $server_url       = undef,) {
  $redbox_package = $packages[package]
  $redbox_system  = $packages[system]
  $target_path    = "${install_parent_directory}/${redbox_system}/${server_directory}"

  package { $redbox_package: } ->
  redbox::update_server_url { $redbox_system:
    has_ssl                  => $has_ssl,
    server_url               => $server_url,
    install_parent_directory => $install_parent_directory,
  } ->
  exec { "restart_if_not_running":
    command   => "service ${redbox_system} restart",
    tries     => 2,
    timeout   => 20,
    try_sleep => 3,
    user      => $owner,
    cwd       => $target_path,
    creates   => "${target_path}/tf.pid",
    logoutput => true,
  }

  # problem possibly with chkconfig not picked up by puppet - so use exec
  # service { 'redbox':
  #  enable => true,
  #  ensure => running,
  #}
}