# Configures NGINX
class deploy_router::nginx_config {
  class { 'nginx':
    stream => true,
  }

  nginx::resource::server { 'gitlab_server' :
    ensure      => present,
    server_name => [
      $::gitlab_external_url,
    ],
    listen_port => 443,
    ssl         => true,
    ssl_cert    => "/etc/letsencrypt/live/${::gitlab_external_url}/fullchain.pem",
    ssl_key     => "/etc/letsencrypt/live/${::gitlab_external_url}/privkey.pem",
    proxy       => 'https://10.99.0.25',
  }

  nginx::resource::upstream {'gitlab_ssh_upstream':
    ensure  => present,
    context => 'stream',
    members => {
      "10.99.0.25:${::gitlab_ssh_port}" => {
        server => '10.99.0.25',
        port   => 22,
      },
    },
  }

  nginx::resource::streamhost {'gitlab_ssh':
    ensure      => present,
    listen_ip   => '10.45.0.11',
    listen_port => $::gitlab_ssh_port,
    proxy       => 'gitlab_ssh_upstream'
  }

  nginx::resource::upstream {'gitlab_registry_upstream':
    ensure  => present,
    context => 'stream',
    members => {
      "10.99.0.25:${::gitlab_registry_port}" => {
        server => '10.99.0.25',
        port   => $::gitlab_registry_port,
      },
    },
  }

  nginx::resource::streamhost {'gitlab_registry':
    ensure      => present,
    listen_ip   => '10.45.0.11',
    listen_port => $::gitlab_registry_port,
    proxy       => 'gitlab_registry_upstream'
  }

  # Serve the NGINX directory for LetsEncrypt certs
  nginx::resource::server { '10.99.0.1':
    www_root  => '/opt/certs',
    listen_ip => '10.99.0.1',
  }

}
