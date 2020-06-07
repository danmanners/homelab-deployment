# Install and configure Gitlab CE
plan deploy_applications::gitlab_ce (
  String $gitlab_url = lookup(gitlab::gitlab_external_url),
) {

  # Install the puppet agent.
  apply_prep('gitlab')

  apply('gitlab', _run_as => root) {

    $gitlab_external_url = lookup('gitlab::gitlab_external_url')
    $gitlab_le_contact_email = lookup('gitlab::gitlab_le_contact_email')

    # Install the prerequesite packages.
    $packages = [
      'curl',
      'openssh-server',
      'ca-certificates',
      'postfix',
    ]

    # Install all of the necessary packages.
    package {$packages:
      ensure => true
    }

    # Add the gitlab repo
    apt::key {'F6403F6544A38863DAA0B6E03F01618A51312F3F':
      ensure => present,
      server => 'https://packages.gitlab.com/gpg.key',
    }

    # Download and add the Gitlab Repo
    file {'/etc/apt/sources.list.d/gitlab_gitlab-ce.list':
      source => "https://packages.gitlab.com/install/repositories/gitlab/gitlab-ce/config_file.list?os=${os['distro']['id']}&dist=${os['distro']['codename']}",
    }

    # Create the proper environment variable to configure gitlab.
    file { '/etc/profile.d/env.sh':
      content => "export EXTERNAL_URL='${gitlab_external_url}'"
    }
  }

  # Run 'apt update'
  apply('gitlab', _run_as => root) {
    include ::apt
  }

  # Install and configure Gitlab.
  apply('gitlab', _run_as => root) {
    package {'gitlab-ce':
      ensure => true,
      before => File['/etc/gitlab/gitlab.rb'],
    }

    file {'/etc/gitlab/gitlab.rb':
      content => epp('deploy_applications/gitlab.rb.epp'),
    }

    exec {'gitlab reconfigure':
      command => '/usr/bin/gitlab-ctl reconfigure',
      require => File['/etc/gitlab/gitlab.rb']
    }

  }
}
