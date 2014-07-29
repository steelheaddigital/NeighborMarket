class neighbormarket::my_fw(
	$environment   = 'development'
){
	resources {"firewall":
		purge => true
	}
    Firewall {
        before  => Class['neighbormarket::my_fw::post'],
        require => Class['neighbormarket::my_fw::pre'],
    }
    class { ['neighbormarket::my_fw::pre', 'neighbormarket::my_fw::post']: }
    class { 'firewall': }
}

class neighbormarket::my_fw::pre {
  Firewall {
    require => undef,
  }
 
  # Default firewall rules
  firewall { '000 accept all icmp':
    proto   => 'icmp',
    action  => 'accept',
  }->
  firewall { '001 accept all to lo interface':
    proto   => 'all',
    iniface => 'lo',
    action  => 'accept',
  }->
  firewall { '002 accept related established rules':
    proto   => 'all',
    state   => ['RELATED', 'ESTABLISHED'],
    action  => 'accept',
  }->
  firewall { '003 allow SSH access':
    port   => 22,
    proto  => tcp,
    action => accept,
  }->
  firewall { '100 allow http access':
   port   => 80,
   proto  => tcp,
   action => accept,
  }->
  firewall { '101 allow https access':
   port   => 443,
   proto  => tcp,
   action => accept,
  }->
  firewall { '102 allow postgres access':
   port   => 5432,
   proto  => tcp,
   action => accept,
  }
  
  if $environment == 'development' {
	  firewall { '004 allow ssh access for vagrant access':
	   port   => 2222,
	   proto  => tcp,
	   action => accept,
	  }
  }
}

class neighbormarket::my_fw::post {
  firewall { '999 drop all':
    proto   => 'all',
    action  => 'drop',
    before  => undef,
  }
}