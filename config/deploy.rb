require 'bundler/capistrano'
load 'deploy/assets'

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
set :repository, "nmpadm@108.166.122.238:neighbor_market/nmp.git"
set :deploy_via, :remote_cache

#############################################################
#    Rvm
#############################################################
require "rvm/capistrano"
set :rvm_ruby_string, '1.9.3'

namespace :deploy do
  desc "cause Passenger to initiate a restart"
  task :restart do
    run "touch #{current_path}/tmp/restart.txt" 
  end
  desc "reload the database with seed data"
  task :seed do
    run "cd #{current_path}; rake db:seed RAILS_ENV=#{rails_env}"
  end
end