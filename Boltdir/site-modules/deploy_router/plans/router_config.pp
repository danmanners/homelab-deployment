# This plan will configure the Proxmox Router.
# This is the ONLY host that will not be a GenericCloud Cent7 Image.
plan deploy_router::router_config() {
  # Prep the server
  apply_prep('bastion')

  # Install Qemu-Guest-Agent and ensure the service is enabled and started.
  apply('bastion', _run_as => root) {

    # Add the Sysctl options to the remote server.
    class { 'easy_sysctl': }

    # List of packages.
    $package_list = [
      'qemu-guest-agent',
      'iptables-persistent'
    ]

    # Install the list of packages.
    package {$package_list:
      ensure => 'installed',
    }

    # Make sure that the qemu-guest-agent is enabled on system startup.
    service {'qemu-service':
      ensure => true,
      name   => 'qemu-guest-agent',
      enable => true,
    }
  }

  apply('bastion', _run_as => root) {
    include deploy_router::iptables_settings
  }

}
