class redbox_shibboleth::execute_script(
   $exec_path = [
      '/usr/local/bin',
      '/opt/local/bin',
      '/usr/bin',
      '/usr/sbin',
      '/bin',
      '/sbin'],
    $path = undef,
) {
   Exec {
    path => $exec_path,
    logoutput => true,
  }
  
  exec { "sh $path" :}
}