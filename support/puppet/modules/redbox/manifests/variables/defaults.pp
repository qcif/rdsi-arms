  
class redbox::variables::defaults {
  $redbox_user = 'redbox'

  $directories = [ 'redbox', 'mint', 'deploy', ]

  $static_files = [ 'deploy.sh', 'redbox.cron', 'redbox-mint.sh', 'apache', ] 

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
