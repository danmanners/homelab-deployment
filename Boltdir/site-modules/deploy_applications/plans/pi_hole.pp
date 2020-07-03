# Performs an Unattended deployment of Pi-Hole.
plan deploy_applications::pi_hole(
){
  apply_prep('pihole')

  apply('pihole', '_run_as' => 'root') {

    # Load values from Hiera
    $webpassword    = lookup('common::pihole::webpassword')
    $ipv4_addr      = lookup('common::pihole::ipv4_addr')
    $upstream_dns_1 = lookup('common::pihole::upstream_dns_1')
    $upstream_dns_2 = lookup('common::pihole::upstream_dns_2')

    file{'/etc/pihole':
      ensure => directory,
      mode   => '0777'
    }

    file{'/etc/pihole/setupVars.conf':
      ensure  => file,
      content => epp('deploy_applications/pihole-setupVars.conf.epp'),
    }

    exec{'install_pihole':
      command => '/usr/bin/curl -L https://install.pi-hole.net | /bin/bash /dev/stdin --unattended',
      require => File['/etc/pihole/setupVars.conf']
    }

  }
}
