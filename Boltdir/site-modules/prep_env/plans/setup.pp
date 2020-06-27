# Sets up your homelab environment requirements
plan prep_env::setup () {
  apply_prep('application_servers')

  apply('application_servers', _run_as => root) {
    include deploy_applications::install_reqs
  }
}
