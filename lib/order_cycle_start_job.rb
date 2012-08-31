class OrderCycleStartJob
  require 'rails'
  
  def perform
    pending_cycle = OrderCycle.find_by_status("pending")
    pending_cycle.status = "current"
    if pending_cycle.save
      queue_order_cycle_end_job(pending_cycle.end_date)
    end
  end
  
  def queue_order_cycle_end_job(end_date)
    job = OrderCycleEndJob.new
    Delayed::Job.where(:queue => "order_cycle_end").each do |job|
      job.destroy
    end
    Delayed::Job.enqueue(job, 0, end_date, :queue => 'order_cycle_end')
  end
  
end
