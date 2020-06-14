# Initializes the Kubernetes worker nodes.
plan deploy_k8s::init_workers () {
  apply_prep(['k8s-nodes'])

  apply('k8s-nodes', _run_as => root) {
    sysctl { 'net.netfilter.nf_conntrack_count':
      ensure  => present,
      value   => '0',
      comment => 'Required for Kubernetes',
    }
    class {'kubernetes':
      worker  => true,
      require => Sysctl['net.netfilter.nf_conntrack_count']
    }
  }
}
