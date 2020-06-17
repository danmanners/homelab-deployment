# Sets up the crontab for Google DynDNS
plan deploy_router::google_dyndns () {
  apply_prep(['bastion'])

  apply('bastion', _run_as => root) {

    $username = lookup('cron::google_dyn_username')
    $password = lookup('cron::google_dyn_password')
    $dyndns   = lookup('cron::google_dyn_domain')

    cron { 'google_dyndns_setup':
      command => "curl -XPOST \"https://${username}:${password}@domains.google.com/nic/update?hostname=${dyndns}&myip=$(curl -s https://icanhazip.com)\"",
      user    => 'root',
      minute  => 15,
    }
  }
}
