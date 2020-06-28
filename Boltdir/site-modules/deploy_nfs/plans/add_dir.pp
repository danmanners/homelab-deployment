# Run this plan to add a new directory to the NFS server.
plan deploy_nfs::add_dir(
  TargetSpec $newdir,
  TargetSpec $mount,
) {
  apply('nfs', _run_as => root){
    file{"/mnt/${mount}/${newdir}":
      ensure => directory,
      mode   => '0777'
    }
  }
}
