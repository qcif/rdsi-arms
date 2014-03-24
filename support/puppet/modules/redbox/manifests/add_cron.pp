define redbox::add_cron (
  $crontab = $title,) {
  cron { $crontab[name]:
    command => $crontab[command],
    user    => $crontab[user],
    hour    => $crontab[hour],
    minute  => $crontab[minute],
  }

}