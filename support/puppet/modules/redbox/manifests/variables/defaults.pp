  
class redbox::variables::defaults {
  $redbox_user = 'redbox'

  $port = '9000'

  $web_path = 'redbox/rdsi'

  $directories = [ 'redbox', 'mint', 'deploy', ]

  $static_files = [ 'deploy.sh', 'redbox.cron', 'redbox-mint.sh', ] 

  $exec_path = [
      '/usr/local/bin',
      '/opt/local/bin',
      '/usr/bin',
      '/usr/sbin',
      '/bin',
      '/sbin']

  case $operatingsystem {
      'centos' : {
        $package_type = 'yum'
      }
      'ubuntu' : {
        $package_type = 'dpkg'
      }
  }
}
