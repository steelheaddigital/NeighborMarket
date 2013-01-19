# Use this file to easily define all of your cron jobs.
#
# It's helpful, but not entirely necessary to understand cron before proceeding.
# http://en.wikipedia.org/wiki/Cron

# Example:
#
# set :output, "/path/to/my/cron_log.log"
#
# every 2.hours do
#   command "/usr/bin/some_great_command"
#   runner "MyModel.some_method"
#   rake "some:great:rake:task"
# end
#
# every 4.days do
#   runner "AnotherModel.prune_old_records"
# end

# Learn more: http://github.com/javan/whenever


#hit the site every five minutes to keep the passenger process alive
env = environment ? environment : 'production'
app_config = YAML::load(File.open("#{env}.yml"))
app_config = YAML.load_file("#{Rails.root}/config/main_conf.yml")
host = app_config["#{env}"]['host']
every 5.minutes do
  command "curl --silent http://#{host}/home/refresh", :output => nil
end

#check that delayed job is running and restart it if not
every 1.minute do
  rake "delayed_job:check", :output => nil
end