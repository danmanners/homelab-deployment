# Log into the docker private registry.
class deploy_applications::docker_login {

  class { 'docker':
    version => 'latest',
  }

  docker::registry { "https://${::reg_private_url}:${::reg_port}" :
    username => $::reg_username,
    password => $::reg_password,
  }
}
