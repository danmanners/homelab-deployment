# This plan will configure the Proxmox Router.
# This is the ONLY host that will not be a GenericCloud Cent7 Image.
plan deploy_dhcp::router_config() {
  # Prep the server
  apply_prep('bastion')

  # Install Qemu-Guest-Agent and ensure the service is enabled and started.
  apply('bastion', _run_as => root) {

    class { 'easy_sysctl': }

    # List of packages
    $package_list = ['qemu-guest-agent']

    package {$package_list:
      ensure => 'installed',
    }

    service {'qemu-service':
      ensure => true,
      name   => 'qemu-guest-agent',
      enable => true,
    }
  }
}
