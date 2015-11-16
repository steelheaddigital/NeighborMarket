class neighbormarket::user (
  $home,
  $user,
  $group,
  $environment
) {

  if $environment == 'development' {
    user { "vagrant":
      groups   => 'adm'
    }
  }

  group { $group:
    ensure => present,
  }->
  user { $user:
    ensure   => present,
    gid      => $group,
    shell    => '/bin/bash',
    home     => $home,
    groups   => 'adm'
  }->
  file { [$home,
          "$home/.ssh",
          "$home/shared",
          "$home/shared/config",
          "$home/certs"]:
    ensure => 'directory',
    owner  => $user,
    group  => $group
  }->
  file { "$home/.ssh/authorized_keys":
    source  => "puppet:///modules/neighbormarket/neighbormarket.pub",
    mode    => '600',
    owner   => $user,
    group   => $group,
  }
  class { 'sudo':
    purge               => false,
    config_file_replace => false,
  }
  sudo::conf { 'neighbormarket':
    priority => 10,
    content  => "%neighbormarket ALL=(ALL) NOPASSWD: ALL",
  }
}
