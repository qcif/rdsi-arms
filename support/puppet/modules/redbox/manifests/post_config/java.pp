# On Debian systems, if alternatives are set, manually assign them.
class redbox::post_config::java ( ) {
  case $::osfamily {
    Debian: {
      if $redbox::variables::java::use_java_alternative != undef and $redbox::variables::java::use_java_alternative_path != undef {
        exec { 'update-java-alternatives':
          path    => '/usr/bin:/usr/sbin:/bin:/sbin',
          command => "update-java-alternatives --set ${redbox::variables::java::use_java_alternative} --jre",
          unless  => "test /etc/alternatives/java -ef '${redbox::variables::java::use_java_alternative_path}'",
        }
      }
    }
    default: {
      # Do nothing.
    }
  }
}
