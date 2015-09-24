node 'vsim-01' {
  netapp_vserver { 'vserver01':
    ensure          => present,
    rootvol         => 'vserver01_root',
    rootvolaggr     => 'aggr1',
    rootvolsecstyle => 'unix',
  }
  netapp_lif { 'vserver01_lif':
    ensure        => present,
    homeport      => 'e0c',
    homenode      => 'VSIM-01',
    address       => '10.0.207.5',
    vserver       => 'vserver01',
    netmask       => '255.255.255.0',
    dataprotocols => ['nfs'],
  }
}