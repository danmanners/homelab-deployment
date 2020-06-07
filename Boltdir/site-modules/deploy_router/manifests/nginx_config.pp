# Configures NGINX
class deploy_router::nginx_config {
  class { 'nginx':  }

  nginx::resource::server { $::gitlab_external_url:
    listen_port => 80,
    proxy       => 'http://10.99.0.25',
  }
}
