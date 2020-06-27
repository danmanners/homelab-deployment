# This plan will be used to deploy the puppet agent to Proxmox
plan manage_proxmox::prep_proxmox() {
  apply_prep('proxmox')

  apply('proxmox') {
    proxmox_api::qemu::clone {'test':
      node             => 'pmx',
      clone_id         => 1001,
      vm_name          => 'TesterMcTesterson',
      disk_size        => 20,
      cpu_cores        => 2,
      memory           => 4096,
      ipv4_static      => true,
      ipv4_static_cidr => '192.168.1.20/24',
      ipv4_static_gw   => '192.168.1.1',
      ci_username      => 'root',
      ci_password      => 'password',
      protected        => true,
    }
  }
}
