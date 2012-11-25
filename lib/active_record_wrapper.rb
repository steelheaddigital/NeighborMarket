module ActiveRecordWrapper
  
  require 'rubygems'
  require 'active_record'
  require 'yaml'
  require 'logger'

  require_relative '../app/models/site_setting'
  require_relative '../app/models/session'

  env = ENV["RAILS_ENV"] ? ENV["RAILS_ENV"] : 'development'
  dbconfig = YAML::load(File.open('config/database.yml'))
  ActiveRecord::Base.establish_connection(dbconfig[env])
  ActiveRecord::Base.logger = Logger.new(STDERR)
  
end