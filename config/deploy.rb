require 'bundler/capistrano'

#############################################################
#    Application
#############################################################

set :application, "neighbor_market"
set :deploy_to, "/home/nmpadm/neighbor_market/"

#############################################################
#    Settings
#############################################################

#default_run_options[:pty] = true
ssh_options[:forward_agent] = true
set :use_sudo, false
set :scm_verbose, true
set :rails_env, "production"

#############################################################
#    Servers
#############################################################

set :user, "nmpadm"
set :domain, "108.166.122.238"
role :app, domain
role :web, domain
role :db, domain, :primary => true

#############################################################
#    Git
#############################################################
set :scm, :git
set :branch, "master"
set :repository, "nmpadm@108.166.122.238:git/nmp.git"
#set :deploy_via, :remote_cache

#############################################################
#    Rvm
#############################################################
require "rvm/capistrano"
set :rvm_ruby_string, '1.9.3'

#############################################################
#    Whenever
#############################################################
require "whenever/capistrano"
set :whenever_command, "bundle exec whenever"

after "deploy:update_code", "deploy:migrate"
after "deploy", "deploy:refresh_site"

namespace :deploy do
  desc "cause Passenger to initiate a restart"
  task :restart do
    run "touch #{current_path}/tmp/restart.txt" 
  end
  
  desc "loads sample data"
  task :load_sample_data do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec rails runner script/load_users.rb"
    run "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec rails runner script/load_inventory_items.rb"
  end
  
  desc "refreshes site so that first load is not slow"
  task :refresh_site do
    env = rails_env ? rails_env : 'production'
    app_config = YAML::load(File.open("config/main_conf.yml"))
    host = app_config["#{env}"]['host']
    run "curl --silent http://#{host}/home/refresh"
  end
end

namespace :inital_deploy do
  deploy
end

namespace :db do
  desc "set up the database including creation and seeding"
  task :setup do
    run "cd #{current_path}; bundle exec rake db:setup RAILS_ENV=#{rails_env}"
  end
  
  desc "create the database with seed data"
  task :create do
    run "cd #{current_path}; bundle exec rake db:create RAILS_ENV=#{rails_env}"
  end
  
  desc "reload the database with seed data"
  task :seed do
    run "cd #{current_path}; bundle exec rake db:seed RAILS_ENV=#{rails_env}"
  end
  
  desc "reset the database"
  task :reset do
    run "cd #{current_path}; bundle exec rake db:reset RAILS_ENV=#{rails_env}"
  end
end


