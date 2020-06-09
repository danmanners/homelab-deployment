# Installs and configured NGINX Reverse Proxy.
plan deploy_router::nginx () {

  # Apply Prep.
  apply_prep('bastion')

  # Install NGINX.
  apply('bastion', _run_as => root) {
    package { 'certbot' :
      ensure => true,
    }

    include nginx
  }

  # Configure NGINX.
  apply('bastion', _run_as => root) {

    # Define the relevant variables.
    $gitlab_external_url  = lookup('gitlab::gitlab_external_url')
    $gitlab_registry_port = lookup('gitlab::gitlab_registry_port')
    $gitlab_ssh_port      = lookup('gitlab::gitlab_ssh_port')

    # Makes sure to remove the default.conf file.
    file { '/etc/nginx/conf.d/default.conf':
      ensure => absent,
    }

    file {'/opt/certs':
      ensure => directory,
      owner  => 'www-data',
      group  => 'www-data',
    }

    # Configure NGINX.
    include deploy_router::nginx_config
  }

  # Install and run Certbot
  apply('bastion', _run_as => root) {

    # Define the relevant variables.
    $gitlab_external_url  = lookup('gitlab::gitlab_external_url')

    exec { 'register or renew LE Cert' :
      command => "/usr/bin/certbot certonly --standalone --preferred-challenges \
                  http -d ${gitlab_external_url} -n",
    }

    exec { "${gitlab_external_url}_cert_setup":
      command => "/bin/mkdir -p /opt/certs/${gitlab_external_url} && \
                    cp /etc/letsencrypt/live/${gitlab_external_url}/* /opt/certs/${gitlab_external_url} && \
                    chown -R www-data:www-data /opt/certs/${gitlab_external_url} && \
                    chmod 0400 /opt/certs/${gitlab_external_url}/*",
      require => Exec['register or renew LE Cert'],
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
