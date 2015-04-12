node 'development.neighbormarket.local' {
  class { 'neighbormarket':
    hostname         => $fqdn,
    environment      => 'development',
    ruby_version     => '2.2.0',
    app_directory    => '/vagrant',
    user             => 'neighbormarket',
    group            => 'neighbormarket',
    db_host          => 'localhost',
    db_port          => '5432',
    db_name          => 'neighbormarket_development',
    db_username      => 'neighbormarket',
    db_password      => 'neighbormarket',
    db_root_password => 'neighbormarket_root'
  }
}

node 'demo.neighbormarket.org' {
  class { 'neighbormarket':
    hostname         => $fqdn,
    environment      => 'production',
    ruby_version     => '2.2.0',
    app_directory    => '/home/neighbormarket',
    user             => 'neighbormarket',
    group            => 'neighbormarket',
    db_host          => 'localhost',
    db_port          => '5432',
    db_name          => 'neighbormarket_production',
    db_username      => 'neighbormarket',
    db_password      => 'neighbormarket',
    db_root_password => 'neighbormarket_root'
  }
}

node 'production.neighbormarket.org' {
  class { 'neighbormarket':
    hostname         => $fqdn,
    environment      => 'production',
    ruby_version     => '2.2.0',
    app_directory    => '/home/neighbormarket',
    user             => 'neighbormarket',
    group            => 'neighbormarket',
    db_host          => 'localhost',
    db_port          => '5432',
    db_name          => 'neighbormarket_production',
    db_username      => 'neighbormarket',
    db_password      => 'neighbormarket',
    db_root_password => 'neighbormarket_root'
  }
}