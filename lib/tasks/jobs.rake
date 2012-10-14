# Rakefile
namespace :jobs do
  desc "checks for delayed jobs and executes if any are ready"
  task :execute => :environment do
    queued_jobs = Delayed::Job.where('run_at <= ?', DateTime.now.utc)
    if queued_jobs
      puts "executing jobs"
      queued_jobs.each do |job|
        worker = Delayed::Worker.new
        worker.run(job)
      end
    end
  end
end