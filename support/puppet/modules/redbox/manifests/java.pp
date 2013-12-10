class redbox::java(
  $version  = 'present',
) {

  class {'redbox::variables::java':}
  ->
  package { 'java':
    ensure => $version,
    name   => $variables::java::use_java_package_name,
  }
  ->
  class { 'redbox::post_config::java': }

}
