class redbox::variables::java {
  $distribution = 'jdk'
  $package = undef
  $java_alternative = undef
  $java_alternative_path = undef
  $rel_long = '1.7.0'
  $rel_short = '7'

  case $::osfamily {
    default: { fail("unsupported platform ${::osfamily}") }
    'RedHat': {
      case $::operatingsystem {
        default: { fail("unsupported os ${::operatingsystem}") }
        'RedHat', 'CentOS': {
            $jdk_package = "java-${rel_long}-openjdk-devel"
            $jre_package = "java-${rel_long}-openjdk"
        }
      }
      $java = {
        'jdk' => { 'package' => $jdk_package, },
        'jre' => { 'package' => $jre_package, },
      }
    }
    'Debian': {
      case $::lsbdistcodename {
        default: { fail("unsupported release ${::lsbdistcodename}") }
        'quantal','raring': {
          $java =  {
            'jdk' => {
              'package'          => "openjdk-${rel_short}-jdk",
              'alternative'      => "java-${rel_long}-openjdk-${::architecture}",
              'alternative_path' => "/usr/lib/jvm/java-${rel_long}-openjdk-${::architecture}/bin/java",
            },
            'jre' => {
              'package'          => "openjdk-${rel_short}-jre-headless",
              'alternative'      => "java-${rel_long}-openjdk-${::architecture}",
              'alternative_path' => "/usr/lib/jvm/java-${rel_long}-openjdk-${::architecture}/bin/java",
            },
          }
        }
      }
    }
  }

  if has_key($java, $distribution) {
    $default_package_name     = $java[$distribution]['package']
    $default_alternative      = $java[$distribution]['alternative']
    $default_alternative_path = $java[$distribution]['alternative_path']
  } else {
    fail("Java distribution ${distribution} is not supported.")
  }

  $use_java_package_name = $package ? {
    default => $package,
    undef   => $default_package_name,
  }

  ## If $java_alternative is set, use that.
  ## Elsif the DEFAULT package is being used, then use $default_alternative.
  ## Else undef
  $use_java_alternative = $java_alternative ? {
    default => $java_alternative,
    undef   => $use_java_package_name ? {
      $default_package_name => $default_alternative,
      default               => undef,
    }
  }

  ## Same logic as $java_alternative above.
  $use_java_alternative_path = $java_alternative_path ? {
    default => $java_alternative_path,
    undef   => $use_java_package_name ? {
      $default_package_name => $default_alternative_path,
      default               => undef,
    }
  }

}
