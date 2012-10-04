class OrderCycle < ActiveRecord::Base
  require 'order_cycle_end_job'
  has_many :orders 
  validate :end_date_not_before_today,
           :end_date_not_before_start_date,
           :seller_delivery_date_not_before_end_date,
           :seller_delivery_date_not_after_next_cycle_start_date,
           :buyer_pickup_date_not_before_seller_delivery_date,
           :buyer_pickup_date_not_after_next_cycle_start_date,
           :next_end_date_not_before_next_start_date,
           :next_end_date_not_before_now
  
  attr_accessible :start_date, :end_date, :status, :seller_delivery_date, :buyer_pickup_date ,:status 
  
  before_validation :get_current_cycle_settings
  def get_current_cycle_settings
    @current_cycle_settings = OrderCycleSetting.first
  end
  
  before_save do |cycle|
    current_order_cycle = cycle.current_cycle
    if current_order_cycle
      current_order_cycle.update_column(:status, "complete")
    end
  end
  
  def self.build_initial_cycle(order_cycle_params, order_cycle_settings)
    settings = order_cycle_settings
    order_cycle = self.new(order_cycle_params)
    if settings.recurring
      interval = settings.interval.pluralize.to_sym
      order_cycle.end_date = order_cycle.start_date.advance(interval => 1)
    end
    
    return order_cycle
  end
  
  def end_date_not_before_today
    if end_date.to_date < Date.current
      errors.add(:end_date, 'cannot be before today') 
    end
  end
  
  def end_date_not_before_start_date
    if end_date < start_date
      errors.add(:end_date, 'cannot be before start date') 
    end
  end
  
  def seller_delivery_date_not_before_end_date
    if seller_delivery_date < end_date
      errors.add(:seller_delivery_date, 'cannot be before end date')
    end
  end
  
  def buyer_pickup_date_not_before_seller_delivery_date
    if buyer_pickup_date < seller_delivery_date
      errors.add(:buyer_pickup_date, 'cannot be before seller delivery date')
    end
  end
  
  def seller_delivery_date_not_after_next_cycle_start_date
    if @current_cycle_settings.recurring
      next_start_date = end_date.advance(@current_cycle_settings.padding_interval.to_sym => @current_cycle_settings.padding)
      if next_start_date < seller_delivery_date
        errors.add(:seller_delivery_date, 'cannot be after the next calculated start date of ' + next_start_date.strftime("%m/%d/%Y %I:%M %p"))
      end
    end
  end
  
  def buyer_pickup_date_not_after_next_cycle_start_date
    if @current_cycle_settings.recurring
      next_start_date = end_date.advance(@current_cycle_settings.padding_interval.to_sym => @current_cycle_settings.padding)
      if next_start_date < buyer_pickup_date
        errors.add(:buyer_pickup_date, 'cannot be after the next calculated start date of ' + next_start_date.strftime("%m/%d/%Y %I:%M %p"))
      end
    end
  end
  
  def next_end_date_not_before_next_start_date
    if @current_cycle_settings.recurring
      next_start_date = end_date.advance(@current_cycle_settings.padding_interval.to_sym => @current_cycle_settings.padding)
      next_end_date = end_date.advance(@current_cycle_settings.interval.pluralize.to_sym => 2)
      if next_end_date < next_start_date
        errors.add(:end_date, 'of '+ next_end_date.strftime("%m/%d/%Y %I:%M %p") + ' cannot be before the next calculated start date of ' + next_start_date.strftime("%m/%d/%Y %I:%M %p") + '. Check the value of Padding.')
      end
    end
  end
  
  def next_end_date_not_before_now
    if @current_cycle_settings.recurring
      next_end_date = end_date.advance(@current_cycle_settings.interval.pluralize.to_sym => 2)
      if next_end_date.to_datetime < DateTime.current
        errors.add(:end_date, 'of '+ next_end_date.strftime("%m/%d/%Y %I:%M %p") + ' cannot be today')
      end
    end
  end
  
  
  def current_cycle
    OrderCycle.find_by_status("current")
  end

  def self.current_cycle
    self.find_by_status("current")
  end
  
  def self.pending_delivery
    self.where("buyer_pickup_date >= ?", DateTime.now.utc).first
  end
  
  def self.current_cycle_id
    return current_cycle ? current_cycle.id : 0
  end
end
