# This plan will be used to prep a template
plan manage_proxmox::prep_template() {
  apply_prep('proxmox')

  apply('proxmox') {
    proxmox_api::qemu::create_genericcloud {'centos':
      node              => 'pmx',
      vm_name           => 'Cent7-template',
      ci_username       => 'centos',
      interface         => 'vmbr0',
      stor              => 'nvmestor',
      vmid              =>  9000,
      cloudimage_source => 'https://cloud.centos.org/centos/7/images/CentOS-7-x86_64-GenericCloud.qcow2.xz',
      image_type        => 'xz',
    }

    proxmox_api::qemu::create_genericcloud {'ubuntu':
      node              => 'pmx',
      vm_name           => 'Ubuntu1804-template',
      ci_username       => 'ubuntu',
      interface         => 'vmbr0',
      stor              => 'nvmestor',
      vmid              =>  9001,
      cloudimage_source => 'https://cloud-images.ubuntu.com/bionic/current/bionic-server-cloudimg-amd64.img',
      image_type        => 'img',
    }
  }
}
