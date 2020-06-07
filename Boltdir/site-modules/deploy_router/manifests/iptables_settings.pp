# IPtables Nat Settings
class deploy_router::iptables_settings {

# Make sure that SSH Traffic inbound is not rejected.
    firewall {'20 ssh inbound':
      chain   => 'INPUT',
      iniface => 'eth0',
      proto   => 'tcp',
      dport   => 22,
      action  => 'accept',
    }

# Make sure that all traffic is masqueraded outbound if the VM is used as a router.
    firewall {'100 Masquerade':
      table        => 'nat',
      chain        => 'POSTROUTING',
      proto        => 'all',
      outiface     => 'eth0',
      jump         => 'MASQUERADE',
      random_fully => true,
    }
}
