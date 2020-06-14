# Deploys BIRD to the Router for Kubernetes BGP Usage.
plan deploy_router::bird () {

  apply_prep('bastion')
  apply('bastion', _run_as => root) {

    $bird_packages = [
      'bird', 'bird-bgp'
    ]

    package {$bird_packages:
      ensure => 'latest',
    }

    file {'/etc/bird/bird.conf':
      ensure  => file,
      source  => 'puppet:///modules/deploy_router/bird.conf',
      owner   => 'bird',
      group   => 'bird',
      mode    => '0640',
      require => Package[$bird_packages],
    }

    service {'bird':
      ensure     => true,
      enable     => true,
      hasrestart => false,
      restart    => '/usr/sbin/birdc configure',
      hasstatus  => false,
      pattern    => 'bird',
      require    => File['/etc/bird/bird.conf'],
    }
  }
}
