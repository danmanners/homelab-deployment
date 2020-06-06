class { 'dhcp':
  service_ensure => running,
  dnsdomain      => [
    'pmx.danmanners.io',
    '1.0.10.in-addr.arpa',
  ],
  nameservers  => [::nameservers],
  ntpservers   => [::ntpservers],
  interfaces   => ['eth0'],
  dnsupdatekey => '/etc/bind/keys.d/rndc.key',
  dnskeyname   => 'rndc-key',
  require      => Bind::Key['rndc-key'],
}
