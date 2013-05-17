# Rakefile
require "net/http"

namespace :site_refresh do
  desc "keeps passenger/heroku alive by making a request. Prevents slow initial loads"
  task :refresh do
    env = ENV["RAILS_ENV"] ? ENV["RAILS_ENV"] : 'production'
    app_config = YAML::load(File.open("config/main_conf.yml"))
    domain_string = "http://#{app_config[env]['host']}/home/refresh"
    domain = URI(domain_string)
    Net::HTTP.get(domain)
  end
end