class redbox::add_all_packages($package_type = undef) {

  $packages = [ 'unzip',]
  
  ## start with simple package installations
  package { $packages :
    ensure   => installed,
    provider => $package_type,
  }

  anchor { 'package::begin:': }
  ->
  class {'redbox::java':}
  ->
  class {'redbox::proxy_server':}
  -> anchor { 'package::end': }

}
