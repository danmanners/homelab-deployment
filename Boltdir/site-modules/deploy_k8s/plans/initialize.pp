# Initializes the master Kubernetes node.
plan deploy_k8s::initialize () {
  apply_prep(['k8s-primary','k8s-nodes'])

  apply('k8s-primary', _run_as => root) {
    class {'kubernetes':
      controller => true,
    }
  }
  apply('k8s-nodes', _run_as => root) {
    class {'kubernetes':
      worker => true,
    }
  }
}
