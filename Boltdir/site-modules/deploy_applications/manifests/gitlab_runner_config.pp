# Configure the Gitlab Runner
define deploy_applications::gitlab_runner_config (
  String[1]                       $runner_name      = $title,
  String[1]                       $runner_token     = $::runner_token,
  Enum['register','unregister']   $register_status  = undef,
  Boolean                         $install          = false,
  String[1]                       $list             = 'docker',
) {

  # If true, install the Gitlab Runner.
  if $install == true {
    # Download the Gitlab Runner.
    file {'runner_download':
      path   => "/tmp/gitlab-runner_${facts['os']['architecture']}.deb",
      source => "https://gitlab-runner-downloads.s3.amazonaws.com/latest/deb/gitlab-runner_${facts['os']['architecture']}.deb",
      mode   => '0775',
    }

    # Install the Gitlab Runner.
    package {'runner_install':
      provider => dpkg,
      source   => "/tmp/gitlab-runner_${facts['os']['architecture']}.deb",
      require  => File['runner_download'],
    }
  }

  # Check if you need to register or de-register the 
  if $register_status == 'register' {
    exec {'runner_registration':
      command => "/usr/bin/gitlab-runner register \
                  -n -u 'https://${::gitlab_external_url}/' \
                  -r '${runner_token}' \
                  --executor 'docker' \
                  --docker-image alpine:latest \
                  --description '${runner_name}' \
                  --tag-list '${list}' \
                  --run-untagged='true' \
                  --locked='false' \
                  --access-level='not_protected'",
      onlyif  => '/usr/bin/which gitlab-runner'
    }
  } elsif $::register_status == 'unregister' {
    exec {'runner_deregistration':
      command => "/usr/bin/gitlab-runner unregister \
                  -n -u 'https://${::gitlab_external_url}/' \
                  -r '${::runner_token}'",
      onlyif  => "/bin/grep -F '${::runner_name}' /etc/gitlab-runner/config.toml",
    }
  }
}
