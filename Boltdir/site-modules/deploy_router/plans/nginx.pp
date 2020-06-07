# Installs and configured NGINX Reverse Proxy.
plan deploy_router::nginx () {

  # Install NGINX .
  apply('bastion', _run_as => root) {
    include nginx
  }

  apply('bastion', _run_as => root) {
    
  }
}
