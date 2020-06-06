# This plan will configure the Proxmox Router.
# This is the ONLY host that will not be a GenericCloud Cent7 Image.
plan deploy_dhcp::router_config(
  TargetSpec $subnet_mask,
  TargetSpec $subnet_address,
) {
  # Prep the server
  apply_prep('bastion')

  # Install Qemu-Guest-Agent and ensure the service is enabled and started.
  apply('bastion', _run_as => root) {

    package {'qemu-guest-agent':
      ensure => 'installed', 
    }

    service {'qemu-service':
      name => 'qemu-guest-agent',
      ensure => true,
      enable => true,
    }
  }
}
