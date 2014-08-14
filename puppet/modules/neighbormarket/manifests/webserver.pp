class neighbormarket::webserver (
  $environment   = 'development',
  $hostname      = 'development.neighbormarket.local',
  $app_directory = '/home/neighbormarket'
) {

  if $environment != 'development' {
    file {
      "$app_directory/certs/$hostname.crt":
        source  => "puppet:///modules/neighbormarket/certs/$hostname.crt",
        owner   => $user,
        group   => $group,
        before  => Class['nginx'];

      "$app_directory/certs/$hostname.key":
        source  => "puppet:///modules/neighbormarket/certs/$hostname.key",
        owner   => $user,
        group   => $group,
        before  => Class['nginx'];
	}
  }

  class { 'nginx': 
	  proxy_set_header => [
	    'Host $host',
	    'X-Real-IP $remote_addr',
	    'X-Forwarded-For $proxy_add_x_forwarded_for',
		'X-Forwarded-Proto $scheme'
	  ]
	}

  nginx::resource::upstream { 'neighbormarket_server':
	  ensure  => present,
	  members => [
	    'unix:/tmp/unicorn.sock'
	  ],
  }

  if $environment == 'development' {
    nginx::resource::vhost { $hostname:
      ensure      => present,
      proxy       => 'http://neighbormarket_server',
    }
  } else {
    nginx::resource::vhost { $hostname:
      ensure           => present,
      rewrite_to_https => true,
      ssl              => true,
      ssl_cert         => "$app_directory/certs/$hostname.crt",
      ssl_key          => "$app_directory/certs/$hostname.key",
      proxy            => 'http://neighbormarket_server/'
    }

    $cache_config = {
     'gzip_static' => 'on',
     'expires'     => 'max',
     'add_header'  => 'Cache-Control public'
    }

    nginx::resource::location { "$hostname-assets":
      ensure              => present,
      ssl                 => true,
      www_root            => "$app_directory/current/public",
      location            => '/assets',
      vhost               => $hostname,
      location_cfg_append => $cache_config,
    }

    nginx::resource::location { "$hostname-uploads":
      ensure              => present,
      ssl                 => true,
      www_root            => "$app_directory/current/public",
      location            => '/system',
      vhost               => $hostname,
      location_cfg_append => $cache_config,
    }
  }
}
