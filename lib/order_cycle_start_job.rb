class OrderCycleStartJob

  def perform
    pending_cycle = OrderCycle.find_by_status("pending")
    pending_cycle.status = "current"
    if pending_cycle.save
      OrderCycle.queue_order_cycle_end_job(pending_cycle.end_date)
    end
  end
  
end
