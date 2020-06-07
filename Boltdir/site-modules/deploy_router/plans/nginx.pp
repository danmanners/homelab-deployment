# Installs and configured NGINX Reverse Proxy.
plan deploy_router::nginx () {

  # Apply Prep
  apply_prep('bastion')

  # Install NGINX .
  apply('bastion', _run_as => root) {
    include nginx
  }

  apply('bastion', _run_as => root) {

    $gitlab_external_url = lookup('gitlab::gitlab_external_url')
    include deploy_router::nginx_config
  }
}
