class OrderCycleEndJob
  require 'rails'
  require 'order_cycle_start_job'
  
  def perform
    current_cycle = OrderCycle.find_by_status("current")
    current_cycle_settings = OrderCycleSetting.first
    if current_cycle_settings.recurring
      padding_interval = current_cycle_settings.padding_interval.to_sym
      interval = current_cycle_settings.interval.pluralize.to_sym
      
      new_start_date = current_cycle.end_date.advance(padding_interval => current_cycle_settings.padding)
      new_seller_delivery_date = current_cycle.seller_delivery_date.advance(interval => 1).advance(padding_interval => current_cycle_settings.padding)
      new_buyer_pickup_date = current_cycle.buyer_pickup_date.advance(interval => 1).advance(padding_interval => current_cycle_settings.padding)
      
      new_cycle = OrderCycle.new_cycle({"start_date" => new_start_date.to_s, "status" => "pending", "seller_delivery_date" => new_seller_delivery_date.to_s, "buyer_pickup_date" => new_buyer_pickup_date.to_s}, current_cycle_settings)
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
