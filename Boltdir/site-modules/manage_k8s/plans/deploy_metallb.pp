# Deploys MetalLB to Kubernets
plan manage_k8s::deploy_metallb(
  TargetSpec $target,
){
  apply_prep($target)

  apply($target){
    $kube_dir           = lookup('common::kubectl_directory')
    $peer_gateway       = lookup('common::metallb::peer_gateway')
    $peer_asn           = lookup('common::metallb::peer_asn')
    $my_asn             = lookup('common::metallb::my_asn')
    $available_ip_pool  = lookup('common::metallb::ip_pool')

    exec{'whoami':
      path    => [
        '/usr/bin',
        '/usr/sbin',
        '/bin'
      ],
    }

    file{'/tmp/_deploy_metallb.yaml':
      ensure  => file,
      content => epp('manage_k8s/metallb-config.yaml.epp'),
    }

    exec{'deploy_metallb':
      command => "${kube_dir}/kubectl apply -f /tmp/_deploy_metallb.yaml --kubeconfig /home/${facts['identity']['user']}/.kube/config",
      path    => [
        '/usr/bin',
        '/usr/sbin',
        '/bin'
      ],
      require => File['/tmp/_deploy_metallb.yaml']
    }
  }
}
