class neighbormarket::database (
  $environment      = 'development',
  $db_host          = 'localhost',
  $db_port          = '5432',
  $db_name          = 'neighbormarket_development',
  $db_username      = 'neighbormarket',
  $db_password      = 'neighbormarket',
  $db_root_password = 'neighbormarket_root',
) {

  group { 'postgres':
    ensure => present,
  }->
  user { 'postgres':
    ensure => present,
    gid    => 'postgres',
    shell  => '/bin/bash',
    home   => '/var/lib/postgresql',
  }->
  file { '/var/lib/postgresql':
    ensure => 'directory',
    owner  => 'postgres',
    group  => 'postgres'
  }->
  class { 'postgresql::globals':
    version             => '9.4',
    manage_package_repo => true,
    encoding            => 'UTF8',
    locale              => 'en_US.UTF-8'
  }->
  class { 'postgresql::server':
    listen_addresses => '*',
	ip_mask_allow_all_users => '0.0.0.0/0',
	ipv4acls => ['hostssl all all 0.0.0.0/0 md5']
  }

  $superuser = $environment == 'development'

  postgresql::server::role { $db_username:
    superuser => $superuser,
    password_hash => postgresql_password($db_username, $db_password)
  }->
  postgresql::server::db { $db_name:
    user     => $db_username,
    password => postgresql_password($db_username, $db_password),
  }
  
  package { 'libpq-dev':
    ensure => installed
  }
}
