# Rakefile
require_relative 'active_record_wrapper'

namespace :jobs do
  desc "checks for delayed jobs and executes if any are ready"
  task :execute do
    queued_jobs = Delayed::Job.where('run_at <= ?', DateTime.now.utc)
    if queued_jobs.count > 0
      puts "executing jobs"
      queued_jobs.each do |job|
        worker = Delayed::Worker.new
        worker.run(job)
      end
    end
  end
end