# Initializes the Kubernetes master node.
plan deploy_k8s::init_master () {
  apply_prep(['k8s-primary'])

  apply('k8s-primary', _run_as => root) {
    sysctl { 'net.netfilter.nf_conntrack_count':
      ensure  => present,
      value   => '0',
      comment => 'Required for Kubernetes',
    }
    class {'kubernetes':
      controller => true,
      require    => Sysctl['net.netfilter.nf_conntrack_count']
    }
  }
}
