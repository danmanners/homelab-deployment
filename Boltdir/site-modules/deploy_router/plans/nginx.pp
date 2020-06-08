# Installs and configured NGINX Reverse Proxy.
plan deploy_router::nginx () {

  # Apply Prep.
  apply_prep('bastion')

  # Install NGINX.
  apply('bastion', _run_as => root) {
    include nginx
  }

  # Configure NGINX.
  apply('bastion', _run_as => root) {

    # Define the relevant variables.
    $gitlab_external_url  = lookup('gitlab::gitlab_external_url')
    $gitlab_registry_port = lookup('gitlab::gitlab_registry_port')
    $gitlab_ssh_port      = lookup('gitlab::gitlab_ssh_port')

    # Makes sure to remove the default.conf file.
    file {'/etc/nginx/conf.d/default.conf':
      ensure => absent,
    }

    # Configure NGINX.
    include deploy_router::nginx_config
  }

  # Install and run Certbot
  apply('bastion', _run_as => root) {

    # Define the relevant variables.
    $gitlab_external_url  = lookup('gitlab::gitlab_external_url')

    package {'certbot':
      ensure => true,
    }

    exec { 'register new LE Cert' :
      command => "/usr/bin/certbot certonly \
                    --standalone --preferred-challenges \
                    http -d ${gitlab_external_url} -n",
      require => Package['certbot'],
    }
  }

  # TODO: Get this all working, but right now it doesn't function. Unknown why.
  # Until the code below is working, use the codeblock above to install and run certbot appropriately.
  # Set up LetsEncrypt for the certificate.
  # apply('bastion', _run_as => root) {
  #   # Define the relevant variables.
  #   $gitlab_external_url  = lookup('gitlab::gitlab_external_url')
  #   $email_address        = lookup('common::primay_email_contact')

  #   include deploy_router::letsencrypt
  # }

}
