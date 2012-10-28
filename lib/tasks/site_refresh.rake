# Rakefile
require "net/http"
namespace :site_refresh do
  desc "keeps passenger alive for the site by making a request. Prevents slow initial loads"
  task :refresh => :environment do
    domain = URI(SiteSetting.first.domain)
    Net::HTTP.get(domain)
  end
end