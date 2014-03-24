define redbox::add_yum_repo (
  $repo = $title,) {
  yumrepo { $repo[name]:
    descr    => $repo[descr],
    baseurl  => $repo[baseurl],
    gpgcheck => $repo[gpgcheck],
    enabled  => $repo[enabled],
  } ~>
  exec { 'yum clean all': refreshonly => true, }

}