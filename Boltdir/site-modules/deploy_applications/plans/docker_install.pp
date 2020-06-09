# This plan will Install Docker on all of the docker hosts.
# The plan depends on the router/reverse proxy being configured.
plan deploy_applications::docker_install() {

  # Prep the server
  apply_prep('docker')

  # Confirm that Docker will always start and keep running.
  apply('docker', _run_as => root) {

    # Set the required variables.
    $reg_private_url  = lookup('docker::registry_url')
    $reg_port         = lookup('gitlab::gitlab_registry_port')
    $reg_username     = lookup('docker::registry_user')
    $reg_password     = lookup('docker::registry_pass')

    include deploy_applications::docker_login

  }
}
