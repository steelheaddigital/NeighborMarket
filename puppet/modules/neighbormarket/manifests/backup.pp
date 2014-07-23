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
      content => template('neighbormarket/backup_config.rb.erb'),
      owner   => $user,
      group   => $group;
    }->
    file {
      "${app_directory}/Backup/models/db_backup.rb":
      content => template('neighbormarket/db_backup.rb.erb'),
      owner   => $user,
      group   => $group;
    }->
    file {
      "${app_directory}/Backup/schedules/db_backup.rb":
      content => template('neighbormarket/db_backup_schedule.rb.erb'),
      owner   => $user,
      group   => $group;
    }
}