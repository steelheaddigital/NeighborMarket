# Rakefile
namespace :scheduler do
  desc "Starts the Scheduler worker"
  task :start => :environment do
    require './lib/scheduler.rb'
    Scheduler.start
  end
end
