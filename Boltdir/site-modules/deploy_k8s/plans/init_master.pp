# Initializes the Kubernetes master node.
plan deploy_k8s::init_master () {
  apply_prep(['k8s-primary'])

  apply('k8s-primary', _run_as => root) {
# Ensures the conntrack count value is set to 0.  
    sysctl { 'net.netfilter.nf_conntrack_count':
      ensure  => present,
      value   => '0',
      comment => 'Required for Kubernetes',
    }
    # SonarQube and Elasticsearch Requirements
    sysctl {'vm.max_map_count':
      ensure  => present,
      value   => 262144,
      comment => 'Required for various Kubernetes services',
    }
    sysctl {'fs.file-max':
      ensure  => present,
      value   => 65536,
      comment => 'Required for various Kubernetes services',
    }
# Use the Ubuntu Hiera file and provision the Kubernetes controller.
    class {'kubernetes':
      controller => true,
      require    => Sysctl['net.netfilter.nf_conntrack_count']
    }
  }
}
