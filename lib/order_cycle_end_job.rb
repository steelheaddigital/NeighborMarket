class OrderCycleEndJob
  require 'rails'
  require 'order_cycle_start_job'
  
  def perform
    current_cycle = OrderCycle.find_by_status("current")
    current_cycle_settings = OrderCycleSetting.first
    if current_cycle_settings.recurring
      padding = current_cycle_settings.padding_interval.to_sym
      new_start_date = current_cycle.end_date.advance(padding => current_cycle_settings.padding_interval)
      new_cycle = OrderCycle.new_cycle({"start_date" => new_start_date.to_s, "status" => "pending"}, current_cycle_settings)
      new_cycle.save
      queue_start_job(new_start_date)
    else
      current_cycle.status = "complete"
      current_cycle.save
    end
  end
  
  def queue_start_job(start_date)
    job = OrderCycleStartJob.new
    Delayed::Job.where(:queue => "order_cycle_start").each do |job|
      job.destroy
    end
    Delayed::Job.enqueue(job, 0, start_date, :queue => 'order_cycle_start')
  end
  
end
