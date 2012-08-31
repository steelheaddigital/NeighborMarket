class OrderCycle < ActiveRecord::Base
  require 'order_cycle_end_job'
  has_many :orders 
  validate :start_date_not_before_today,
           :end_date_not_before_today,
           :end_date_not_before_start_date
  
  attr_accessible :start_date, :end_date, :status
  
  before_save do |cycle|
    current_order_cycle = cycle.current_cycle
    if current_order_cycle
      current_order_cycle.update_column(:status, "complete")
    end
  end
  
  def self.new_cycle(order_cycle_params, order_cycle_settings)
    settings = order_cycle_settings
    order_cycle = self.new(order_cycle_params)
    if settings.recurring
      interval = settings.interval.pluralize.to_sym
      order_cycle.end_date = order_cycle.start_date.advance(interval => 1)
    end
    
    return order_cycle
  end
  
  def start_date_not_before_today
    today = Date.current
    start = start_date.to_date
    diff = start - today
    if diff.to_i < 0
      errors.add(:start_date, 'cannot be before today') 
    end
  end
  
  def end_date_not_before_today
    today = Date.current
    ending = end_date.to_date
    diff = ending - today
    if diff.to_i < 0
      errors.add(:end_date, 'cannot be before today') 
    end
  end
  
  def end_date_not_before_start_date
    starting = start_date.to_date
    ending = end_date.to_date
    diff = ending - starting
    if diff.to_i < 0
      errors.add(:end_date, 'cannot be before start date') 
    end
  end
  
  def current_cycle
    OrderCycle.find_by_status("current")
  end

  def self.current_cycle
    self.find_by_status("current")
  end
  
  def self.current_cycle_id
    return current_cycle ? current_cycle.id : 0
  end
end
