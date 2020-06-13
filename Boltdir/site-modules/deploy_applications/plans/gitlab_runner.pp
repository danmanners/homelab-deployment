# Deploy the Gitlab Runners to all docker hosts.
plan deploy_applications::gitlab_runner () {
  apply_prep(['docker'])
  apply('docker', _run_as => root) {
    $runner_token = lookup('gitlab::runner_token')
    $gitlab_external_url = lookup('gitlab::gitlab_external_url')

    deploy_applications::gitlab_runner_config {$::facts['networking']['hostname']:
      runner_token    => $runner_token,
      register_status => 'register',
      install         => true,
      list            => 'docker'
    }
  }
}
