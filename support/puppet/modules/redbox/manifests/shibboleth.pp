class redbox::shibboleth(
  $static_file = "go-redhat",
  $base_url = "https://raw.github.com/ausaccessfed/aasc/master",
  $working_dir = "/home/redbox",
  $entity_id = $::fqdn,
  $shibboleth_env = 'test',  ## test or prod
) {
 
  redbox::add_static_file { $static_file:
    owner  		 => 'root',
    source 		 => $base_url,
  	destination => $working_dir,
  }
  ->
  file_line { 'go_args':
	  path  => "${working_dir}/${static_file}",
	  line  => "./go -i ${entity_id} -e ${shibboleth_env}",
	  match => "^./go.*$",
  }
  ->
  exec { "sh ${working_dir}/${static_file}" :}
  ->
  file { 'attribute-map.xml':
    path    => '/etc/shibboleth/attribute-map.xml',
    ensure  => file,
    source  => "puppet:///modules/redbox/attribute-map.xml",
  }
  
}

