module DelayedJobProcess
  DELAYED_JOB_PID_PATH = File.expand_path("../../tmp/pids/delayed_job.pid", __FILE__)
  def start_delayed_job
    Thread.new do 
      `ruby script/delayed_job start`
    end
  end
  
  def stop_delayed_job
    Thread.new do 
      `ruby script/delayed_job stop`
    end
  end

  def restart_delayed_job
    if daemon_is_running?
      Thread.new do
        `ruby script/delayed_job stop`
        `ruby script/delayed_job start`
      end
    else
      Thread.new do
        `ruby script/delayed_job start`
      end
    end
  end
  
  def check_delayed_job
    if !daemon_is_running?
      Thread.new do
        `ruby script/delayed_job start`
      end
    end
  end

  def daemon_is_running?
    pid = File.read(DELAYED_JOB_PID_PATH).strip
    Process.kill(0, pid.to_i) #check if the delayed_job daemon is running
    true
  rescue Errno::ENOENT, Errno::ESRCH   # file or process not found
    false
  end

end