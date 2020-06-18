# Configures the Kubernetes NFS VM
plan deploy_nfs::setup () {
  apply_prep('nfs')

  apply('nfs', _run_as => root) {
    file {'/mnt/nvmestor':
      ensure => directory,
    }

    mount { '/mnt/nvmestor':
      ensure   => 'mounted',
      device   => '/dev/mapper/k8stor-nvme',
      remounts => true,
      fstype   => 'ext4',
      options  => 'rw',
      require  => File['/mnt/nvmestor']
    }
  }

  apply('nfs', _run_as => root) {
    class { '::nfs':
      server_enabled => true,
    }

    nfs::server::export{ '/mnt/nvmestor':
      ensure  => 'mounted',
      clients => '10.99.0.0/24(rw,insecure,async,no_root_squash) localhost(rw)',
    }
  }
}
