class neighbormarket::backup (
	$app_directory,
	$user,
	$group
) {
    file {
      "${app_directory}/Backup":
  	  ensure => 'directory',
      owner   => $user,
      group   => $group;
    }->
    file {
      "${app_directory}/Backup/models":
  	  ensure => 'directory',
      owner   => $user,
      group   => $group;
    }->
    file {
      "${app_directory}/Backup/schedules":
  	  ensure => 'directory',
      owner   => $user,
      group   => $group;
    }->
    file {
      "${app_directory}/Backup/config.rb":
	  replace => false,
	  ensure => present,
      content => template('neighbormarket/backup_config.rb.erb'),
      owner   => $user,
      group   => $group;
    }->
    file {
      "${app_directory}/Backup/models/db_backup.rb":
	  replace => false,
	  ensure => present,
      content => template('neighbormarket/db_backup.rb.erb'),
      owner   => $user,
      group   => $group;
    }->
    file {
      "${app_directory}/Backup/models/public_backup.rb":
	  replace => false,
	  ensure => present,
      content => template('neighbormarket/public_backup.rb.erb'),
      owner   => $user,
      group   => $group;
    }->
    file {
      "${app_directory}/Backup/schedules/backup.rb":
	  replace => false,
	  ensure => present,
      content => template('neighbormarket/backup_schedule.rb.erb'),
      owner   => $user,
      group   => $group;
    }
}