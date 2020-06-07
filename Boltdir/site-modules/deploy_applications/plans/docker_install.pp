# This plan will Install Docker on all of the docker hosts.
# The plan depends on the router/reverse proxy being configured.
plan deploy_applications::docker_install() {

  # Prep the server
  apply_prep('docker')

  # Install Docker
  apply('docker', _run_as => root) {
    package {'docker.io':
      ensure => true,
    }
  }

  # Confirm that Docker will always start and keep running.
  apply('docker', _run_as => root) {
    service {'docker':
      ensure => true,
      enable => true,
    }
  }
}
