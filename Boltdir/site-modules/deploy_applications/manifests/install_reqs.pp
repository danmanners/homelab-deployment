# Installs all of the platform requiremnts
class deploy_applications::install_reqs() {

  # Create the array of packages to install
  $packages = [
    'qemu-guest-agent',
    'vim', 'nfs-common',
  ]

  package {$packages:
    ensure => 'present',
  }

  service {'qemu-guest-agent':
    ensure => true,
    enable => true,
  }

}
