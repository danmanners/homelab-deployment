# Configure all of LetsEncrypt
class deploy_router::letsencrypt {

  class { 'letsencrypt':
    email          => $::email_address,
    package_ensure => 'latest',
  }

  # Set up the certificate
  letsencrypt::certonly { $::gitlab_external_url: }

}
