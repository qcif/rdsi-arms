define redbox::deploy_archive (
  $archive           = $title,
  $url               = 'http://dev.redboxresearchdata.com.au/nexus/service/local/artifact/maven/redirect',
  $archive_extension = 'tar.gz',
  $deploy_script_path,) {
  $redbox_system = $archive[name]
  $artifact      = $archive[artifact]
  $group         = $archive[group]
  $web_context   = $archive[web_context]
  $version       = $archive[version]
  $classifier    = $archive[classifier]
  $repo          = $archive[repo]
  $source        = "${url}?r=${repo}&g=${group}&a=${artifact}&v=${version}&c=${classifier}&e=${archive_extension}"

  concat::fragment { "deploy_${redbox_system}_fragment":
    target  => $deploy_script_path,
    content => template("redbox/deploy_system_fragment.sh.erb"),
    order   => '10',
  }
}