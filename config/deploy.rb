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

after "deploy", "deploy:migrate"
after "deploy", "deploy:refresh_site"

namespace :deploy do
  desc "cause Passenger to initiate a restart"
  task :restart do
    run "touch #{current_path}/tmp/restart.txt" 
  end
  
  desc "reload the database with seed data"
  task :seed do
    run "cd #{current_path}; bundle exec rake db:seed RAILS_ENV=#{rails_env}"
  end
  
  desc "reset the database"
  task :reset do
    run "cd #{current_path}; bundle exec ps xa | grep postgres: | grep NeighborMarket_production | grep -v grep | awk '{print $1}' | sudo xargs kill | rake db:reset RAILS_ENV=#{rails_env}"
  end
  
  desc "loads sample data"
  task :load_sample_data do
    run "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec rails runner script/load_users.rb"
    run "cd #{current_path}; RAILS_ENV=#{rails_env} bundle exec rails runner script/load_inventory_items.rb"
  end
  
  desc "refreshes site so that first load is not slow"
  task :refresh_site do
    run "cd #{current_path}; bundle exec rake site_refresh:refresh RAILS_ENV=#{rails_env}"
  end
end


