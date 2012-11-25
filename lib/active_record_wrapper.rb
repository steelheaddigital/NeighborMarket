module ActiveRecordWrapper
  
  require 'rubygems'
  require 'active_record'
  require 'yaml'
  require 'logger'

  require_relative '../app/models/site_setting'
  require_relative '../app/models/session'

  dbconfig = YAML::load(File.open('config/database.yml'))
  ActiveRecord::Base.establish_connection(dbconfig['development'])
  ActiveRecord::Base.logger = Logger.new(STDERR)
  
end