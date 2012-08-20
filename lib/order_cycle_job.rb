class OrderCycleJob
  require 'rails'
  
  def perform
    current_cycle = OrderCycle.find_by_current(true)
    current_cycle_settings = OrderCycleSetting.first
    if current_cycle_settings.recurring
      new_cycle = OrderCycle.new_cycle({"start_date" => current_cycle.end_date.to_s, "end_date" => ""}, current_cycle_settings)
      new_cycle.save
    else
      current_cycle.current = false
      current_cycle.save
    end
  end
  
end
