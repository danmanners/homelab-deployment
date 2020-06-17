# Configures the Kubernetes NFS VM
plan deploy_nfs::init () {
  apply_prep('nfs')

  apply('nfs', _run_as => root) {
    class { '::nfs':
      server_enabled => true,
    }
  }
}
