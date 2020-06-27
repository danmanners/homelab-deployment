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

# Make sure that BGP Traffic inbound on the WAN interface is dropped.
    firewall {'30 bgp inbound drop':
      chain   => 'INPUT',
      iniface => 'eth0',
      proto   => 'tcp',
      dport   => 179,
      action  => 'drop',
    }

# Make sure that Gitlab Traffic inbound is not rejected.
    firewall {'40 gitlab ssh':
      chain   => 'INPUT',
      iniface => 'eth0',
      proto   => 'tcp',
      dport   => 2222,
      action  => 'accept',
    }

    firewall {'41 gitlab docker registry':
      chain   => 'INPUT',
      iniface => 'eth0',
      proto   => 'tcp',
      dport   => 5050,
      action  => 'accept',
    }

    firewall {'42 gitlab docker registry':
      chain   => 'INPUT',
      iniface => 'eth0',
      proto   => 'tcp',
      dport   => 6443,
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
