# Initializes the Kubernetes master node.
plan deploy_k8s::init_master (
  Optional[String] $mode = ''
) {
  apply_prep(["${mode}k8s-primary"])

  apply("${mode}k8s-primary", _run_as => root) {
  # Ensures the conntrack count value is set to 0.  
    sysctl { 'net.netfilter.nf_conntrack_count':
      ensure  => present,
      value   => '0',
      comment => 'Required for Kubernetes',
    }

    # SonarQube and Elasticsearch Requirements.
    sysctl {'vm.max_map_count':
      ensure     => present,
      value      => $vm_max_map_count,
      comment    => 'Required for various Kubernetes services',
      persistent => true
    }
    sysctl {'fs.file-max':
      ensure     => present,
      value      => $fs_file_max,
      comment    => 'Required for various Kubernetes services',
      persistent => true
    }

    # Ensure the sysctl settings are persistent.
    file_line{'persistent-vm.max_map_count':
      ensure => present,
      path   => '/etc/sysctl.conf',
      line   => "vm.max_map_count = ${vm_max_map_count}",
      match  => '^vm.max_map_count = '
    }
    file_line{'persistent-fs.file-max':
      ensure => present,
      path   => '/etc/sysctl.conf',
      line   => "fs.file-max = ${fs_file_max}",
      match  => '^fs.file-max = '
    }

    # Use the Ubuntu Hiera file and provision the Kubernetes controller.
    class {'kubernetes':
      controller => true,
      require    => Sysctl['net.netfilter.nf_conntrack_count']
    }
  }
}
