require 'delayed_job_process'
include DelayedJobProcess

namespace :delayed_job do
  desc "check if delayed_job daemon is running and restart it if not"
  task :check do
    check_delayed_job
  end
  
  desc "restart delayed_job daemon"
  task :restart do
    restart_delayed_job
  end
end