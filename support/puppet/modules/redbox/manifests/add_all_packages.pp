class redbox::add_all_packages {
  
  redbox_utilities::add_package {'unzip':}
  ->
  class {'redbox::java':}
  ->
  class {'redbox::proxy_server':}

}
