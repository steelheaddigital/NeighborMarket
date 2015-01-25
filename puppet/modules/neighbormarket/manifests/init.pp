class neighbormarket (
  $hostname         = 'development.neighbormarket.local',
  $environment      = 'development',
  $ruby_version     = '2.2.0',
  $app_directory    = '/home/neighbormarket',
  $user             = 'neighbormarket',
  $group            = 'neighbormarket',
  $db_host          = 'localhost',
  $db_port          = '5432',
  $db_name          = 'neighbormarket_development',
  $db_username      = 'neighbormarket',
  $db_password      = 'neighbormarket',
  $db_root_password = 'neighbormarket_root',
) {

  Exec { path => "/bin:/sbin:/usr/bin:/usr/sbin" }
  
  class { 'neighbormarket::user':
    home  => $app_directory,
    user  => $user,
    group => $group
  }->
  class { 'neighbormarket::my_fw':
  	environment   => $environment
  }->
  class { 'neighbormarket::ruby':
  	version => $ruby_version
  }->
  class { 'neighbormarket::webserver':
    environment   => $environment,
    hostname      => $hostname,
    app_directory => $app_directory
  }->
  class { 'neighbormarket::database':
    environment      => $environment,
    db_host          => $db_host,
    db_port          => $db_port,
    db_name          => $db_name,
    db_username      => $db_username,
    db_password      => $db_password,
    db_root_password => $db_root_password
  }->
  class { 'neighbormarket::backup':
  	app_directory => $app_directory,
	user => $user,
	group => $group
  }->
  file {
    "${app_directory}/shared/config/database.yml":
	  replace => false,
	  ensure => present,
      content => template('neighbormarket/database.yml.erb'),
      owner   => $user,
      group   => $group;
  }
  
  # --- Memcached ----------------------------------------------------------------
  
  class { 'memcached': }
  
  # --- Packages -----------------------------------------------------------------
  
  package { 'git-core':
    ensure => installed
  }
  
  # ImageMagick
  package { 'imagemagick' :
    ensure => present,
  }
  
  package { 'libmagickcore-dev' :
    ensure => present,
  }

  package { 'libmagickwand-dev' :
    ensure => present,
  }
  
  # ExecJS runtime.
  package { 'nodejs':
    ensure => installed
  }
  
  # Nokogiri dependencies.
  package { ['libxml2', 'libxml2-dev', 'libxslt1-dev']:
    ensure => installed
  }
  
  # --- Locale -------------------------------------------------------------------
  exec { 'update-locale':
    command => 'update-locale LANG=en_US.UTF-8 LANGUAGE=en_US.UTF-8 LC_ALL=en_US.UTF-8'
  }
}
