# Installs and ensures that Qemu-Guest-Agent is installed and running as a service.
plan deploy_applications::qemu_guest_agent () {
  apply_prep('application_servers')

  apply('application_servers', _run_as => root) {
    package {'qemu-guest-agent':
      ensure => 'present',
    }

    service {'qemu-guest-agent':
      ensure => true,
      enable => true,
    }
  }
}
