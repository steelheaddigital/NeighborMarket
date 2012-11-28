module ActiveRecordWrapper
  
  require 'rubygems'
  require 'active_record'
  require 'yaml'

  require_relative '../../app/models/site_setting'
  require_relative '../../app/models/session'
  
  env = ENV["RAILS_ENV"] ? ENV["RAILS_ENV"] : 'production'
  dbconfig = YAML::load(File.open('config/database.yml'))
  ActiveRecord::Base.establish_connection(dbconfig[env])
  
end