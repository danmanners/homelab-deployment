# Provisions a new disk
plan deploy_nfs::provision_disk () {
  apply_prep('nfs')

  apply('nfs', _run_as => root) {
    physical_volume { '/dev/sdb':
      ensure => present,
    }

    volume_group { 'k8stor':
      ensure           => present,
      physical_volumes => '/dev/sdb',
    }

    logical_volume { 'nvme':
      ensure       => present,
      volume_group => 'k8stor',
    }

    filesystem { '/dev/k8stor/nvme':
      ensure  => present,
      fs_type => 'ext4',
      options => '-b 4096 -E stride=32,stripe-width=64',
    }

    file {'/opt/k8stor':
      ensure => directory,
    }
  }
}
