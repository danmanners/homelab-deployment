# Configures NGINX
class deploy_router::nginx_config {
  class { 'nginx':
    stream               => true,
    client_max_body_size => '500M'
  }

# Reverse HTTPS Proxy for Gitlab Server
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

# Reverse TCP Proxy for Gitlab SSH
  nginx::resource::streamhost {'gitlab_ssh':
    ensure      => present,
    listen_ip   => '10.45.0.11',
    listen_port => $::gitlab_ssh_port,
    proxy       => 'gitlab_ssh_upstream'
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

# Reverse TCP Proxy for the K8s Control Plane
  nginx::resource::streamhost {'k8s_controlplane':
    ensure      => present,
    listen_ip   => '10.45.0.11',
    listen_port => 6443,
    proxy       => 'k8s_controlplane_upstream'
  }

  nginx::resource::upstream {'k8s_controlplane_upstream':
    ensure  => present,
    context => 'stream',
    members => {
      '10.99.0.20:6443' => {
        server => '10.99.0.20',
        port   => 6443,
      },
    },
  }

# Reverse TCP Proxy for the Gitlab Container Registry
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

### EVERYTHING BELOW THIS LINE SHOULD BE FOR APPLICATIONS ONLY.
### THIS WILL BE BROKEN OUT INTO SEPARATE FILES LATER.
# Reverse HTTP Proxy for PiHole
  # nginx::resource::server { 'pihole_server' :
  #   ensure           => present,
  #   server_name      => [
  #     $::pihole_external_url,
  #   ],
  #   proxy_set_header => [
  #     'Host $host:$server_port',
  #     'X-Real-IP $remote_addr',
  #   ],
  #   listen_port      => 80,
  #   proxy            => 'http://10.99.0.2',
  # }

  nginx::resource::server { 'jenkins_server' :
    ensure           => present,
    server_name      => [
      $::jenkins_external_url,
    ],
    proxy_set_header => [
      'Host $host:$server_port',
      'X-Real-IP $remote_addr',
      'X-Forwarded-For $proxy_add_x_forwarded_for',
      'X-Forwarded-Proto $scheme',
    ],
    listen_port      => 443,
    ssl              => true,
    ssl_cert         => "/etc/letsencrypt/live/${::gitlab_external_url}/fullchain.pem",
    ssl_key          => "/etc/letsencrypt/live/${::gitlab_external_url}/privkey.pem",
    proxy            => 'http://10.99.0.151:8080',
  }

# Reverse HTTPS Proxy for Sonarqube on Kubernetes
  nginx::resource::server { 'sonarqube_server' :
    ensure           => present,
    server_name      => [
      $::sonarqube_external_url,
    ],
    proxy_set_header => [
      'Host $host:$server_port',
      'X-Real-IP $remote_addr',
      'X-Forwarded-For $proxy_add_x_forwarded_for',
      'X-Forwarded-Proto $scheme',
    ],
    listen_port      => 443,
    ssl              => true,
    ssl_cert         => "/etc/letsencrypt/live/${::gitlab_external_url}/fullchain.pem",
    ssl_key          => "/etc/letsencrypt/live/${::gitlab_external_url}/privkey.pem",
    proxy            => 'http://10.99.0.152:9000',
  }

# Reverse HTTPS Proxy for Sammy Ross on Wordpress
  nginx::resource::server { 'sam_server' :
    ensure           => present,
    server_name      => [
      $::sam_external_url,
    ],
    proxy_set_header => [
      'Host $host:$server_port',
      'X-Real-IP $remote_addr',
      'X-Forwarded-For $proxy_add_x_forwarded_for',
      'X-Forwarded-Proto $scheme',
    ],
    listen_port      => 443,
    ssl              => true,
    ssl_cert         => "/etc/letsencrypt/live/${::gitlab_external_url}/fullchain.pem",
    ssl_key          => "/etc/letsencrypt/live/${::gitlab_external_url}/privkey.pem",
    proxy            => 'http://10.45.0.134:8000',
  }

# Reverse HTTPS Proxy for Nexus OSS on Kubernetes
  nginx::resource::server { 'nexus_server' :
    ensure           => present,
    server_name      => [
      $::nexus_external_url,
    ],
    proxy_set_header => [
      'Host $host:$server_port',
      'X-Real-IP $remote_addr',
      'X-Forwarded-For $proxy_add_x_forwarded_for',
      'X-Forwarded-Proto $scheme',
    ],
    listen_port      => 443,
    ssl              => true,
    ssl_cert         => "/etc/letsencrypt/live/${::gitlab_external_url}/fullchain.pem",
    ssl_key          => "/etc/letsencrypt/live/${::gitlab_external_url}/privkey.pem",
    proxy            => 'http://10.99.0.155:8081',
  }

# Reverse HTTPS Proxy for Nexus OSS Docker Registry on Kubernetes
  nginx::resource::server { 'nexus_registry' :
    ensure           => present,
    server_name      => [
      $::nexus_docker_external_url,
    ],
    proxy_set_header => [
      'Host $host:$server_port',
      'X-Real-IP $remote_addr',
      'X-Forwarded-For $proxy_add_x_forwarded_for',
      'X-Forwarded-Proto $scheme',
    ],
    listen_port      => 5001,
    ssl              => true,
    ssl_cert         => "/etc/letsencrypt/live/${::gitlab_external_url}/fullchain.pem",
    ssl_key          => "/etc/letsencrypt/live/${::gitlab_external_url}/privkey.pem",
    proxy            => 'http://10.99.0.155:5001',
  }

# Reverse TCP Proxy for PostgreSQL
  nginx::resource::upstream {'postgres_upstream':
    ensure  => present,
    context => 'stream',
    members => {
      '10.99.0.153:5432' => {
        server => '10.99.0.153',
        port   => 5432,
      },
    },
  }

  nginx::resource::streamhost {'postgres':
    ensure      => present,
    listen_ip   => '10.45.0.11',
    listen_port => 5432,
    proxy       => 'postgres_upstream'
  }
}
