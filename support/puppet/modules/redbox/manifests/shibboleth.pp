class redbox::shibboleth (
  $static_file    = "go-redhat",
  $base_url       = "https://raw.github.com/ausaccessfed/aasc/master",
  $working_dir    = "/home/redbox",
  $entity_path    = "${::fqdn}/shibboleth",
  $shibboleth_env = 'test', # # test or prod
  ) {
  case $shibboleth_env {
    'test'  : { $entity_id = "http://${entity_path}" }
    default : { $entity_id = "https://${entity_path}" }
  }

  redbox::add_static_file { $static_file:
    owner       => 'root',
    source      => $base_url,
    destination => $working_dir,
  } ->
  file_line { 'go_args':
    path  => "${working_dir}/${static_file}",
    line  => "./go -i ${entity_id} -e ${shibboleth_env}",
    match => "^./go.*$",
  } ->
  exec { 'run-setup-script': command => "sh ${working_dir}/${static_file}" } ->
  service { 'shibd': ensure => running, }

  file { 'attribute-map.xml':
    path    => '/etc/shibboleth/attribute-map.xml',
    ensure  => file,
    source  => "puppet:///modules/redbox/attribute-map.xml",
    require => Exec['run-setup-script'],
    notify  => Service['shibd'],
  }

  file_line { 'shibboleth_via_ajp':
    path    => '/etc/shibboleth/shibboleth2.xml',
    line    => 'REMOTE_USER="eppn persistent-id targeted-id" attributePrefix="AJP_">',
    match   => "^[[:blank:]]*REMOTE_USER=.eppn persistent-id targeted-id.*>$",
    require => Exec['run-setup-script'],
    notify  => Service['shibd'],
  }

  if ($shibboleth_env == 'test') {
    file_line { 'shibboleth_no_SSL':
      path    => '/etc/shibboleth/shibboleth2.xml',
      line    => 'checkAddress="false" handlerSSL="false" cookieProps="http">',
      match   => "^[[:space:]]*checkAddress=.*handlerSSL=.*cookieProps=.*>[[:space:]]*$",
      require => Exec['run-setup-script'],
      notify  => Service['shibd'],
    }
  }
}
