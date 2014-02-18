define redbox_utilities::add_package($package = $title) {
  case $operatingsystem {
      'centos' : {
        $package_type = 'yum'
      }
      'ubuntu' : {
        $package_type = 'dpkg'
      }
  }
  
  package { $package :
    ensure   => installed,
    provider => $package_type,
  }
}