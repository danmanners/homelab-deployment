# IPtables Nat Settings
class deploy_router::iptables_settings {

    firewall {'20 ssh inbound':
      chain => 'INPUT',
      iniface => 'eth0',
      proto => 'tcp',
      dport => 22,
      action => 'accept',
    }

    firewall {'100 Masquerade':
      table => 'nat',
      chain => 'POSTROUTING',
      proto => 'all',
      outiface => 'eth0',
      jump => 'MASQUERADE',
      random_fully => true,
    }
    # -A POSTROUTING -o eth0 -j MASQUERADE --random
}
