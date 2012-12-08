module ActiveRecordWrapper
  
  require 'rubygems'
  require 'active_record'
  require 'yaml'

  require_relative '../../app/models/site_setting'
  require_relative '../../app/models/session'
  require_relative '../../app/models/cart'
  require_relative '../../app/models/cart_item'
  require_relative '../../app/models/order_cycle'
  require_relative '../../app/models/order_cycle_setting'
  
  env = ENV["RAILS_ENV"] ? ENV["RAILS_ENV"] : 'production'
  dbconfig = YAML::load(File.open('config/database.yml'))
  ActiveRecord::Base.establish_connection(dbconfig[env])
  
end