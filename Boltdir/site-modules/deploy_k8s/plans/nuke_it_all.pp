# This module will COMPLETELY nuke and pave an existing kubernetes cluster.
# Make sure you know what you're doing if you run this.
# This is entirely destructive and will destroy any and all work you have.
# Once this has been completed, make sure you reboot all of the hosts.
plan deploy_k8s::nuke_it_all (
  Boolean $confirm
) {
# Only if confirm=true should this nuke the cluster and all nodes.
  if $confirm {
    apply(['k8s-primary','k8s-nodes'], _run_as => root) {
      exec {'nuke it all':
        command => '/usr/bin/kubeadm reset -f'
      }

      service {'etcd':
        ensure => stopped,
      }

      file {'/var/lib/etcd/member':
        ensure  => absent,
        purge   => true,
        force   => true,
        recurse => true,
        require => Service['etcd'],
      }
    }
  }
}
