# Rakefile
require "net/http"

namespace :site_refresh do
  desc "keeps passenger alive for the site by making a request. Prevents slow initial loads"
  task :refresh do
    env = ENV["RAILS_ENV"] ? ENV["RAILS_ENV"] : 'production'
    app_config = YAML::load(File.open("#{env}.yml"))
    domain_string = "http://#{app_config['host']}"
    domain = URI(domain_string)
    Net::HTTP.get(domain)
  end
end