# Install and configure Gitlab CE
plan deploy_applications::gitlab_ce (
  String $gitlab_url = lookup(gitlab::gitlab_external_url),
) {

  # Install the puppet agent.
  apply_prep('gitlab')

  apply('gitlab', _run_as => root) {

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
  }

  # Run 'apt update'
  apply('gitlab', _run_as => root) {
    include ::apt
  }

  # Install and configure Gitlab.
  apply('gitlab', _run_as => root) {

    # Set some variables.
    $gitlab_le_contact_email  = lookup('common::primay_email_contact')
    $gitlab_external_url      = lookup('gitlab::gitlab_external_url')
    $gitlab_registry_port     = lookup('gitlab::gitlab_registry_port')
    $gitlab_ssh_port          = lookup('gitlab::gitlab_ssh_port')

    package {'gitlab-ce':
      ensure => true,
      before => File['/etc/gitlab/gitlab.rb'],
    }

    file {'/etc/gitlab/gitlab.rb':
      content => epp('deploy_applications/gitlab.rb.epp'),
    }

    file {"/etc/gitlab/ssl/${gitlab_external_url}.crt":
      source => "http://10.99.0.1/${gitlab_external_url}/fullchain.pem",
    }

    file {"/etc/gitlab/ssl/${gitlab_external_url}.key":
      source => "http://10.99.0.1/${gitlab_external_url}/privkey.pem",
    }

    exec {'gitlab reconfigure':
      command => '/usr/bin/gitlab-ctl reconfigure',
      require => File['/etc/gitlab/gitlab.rb']
    }

  }
}
