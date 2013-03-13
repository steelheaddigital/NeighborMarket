require 'order_cycle_end_job'
require 'order_cycle_start_job'

class OrderCycle < ActiveRecord::Base
  has_many :orders
  has_and_belongs_to_many :inventory_items, :uniq => true
  validate :end_date_not_before_today,
           :end_date_not_before_start_date,
           :seller_delivery_date_not_before_end_date,
           :buyer_pickup_date_not_before_seller_delivery_date,
           :next_end_date_not_before_next_start_date,
           :next_end_date_not_before_now
  
  attr_accessible :start_date, :end_date, :status, :seller_delivery_date, :buyer_pickup_date ,:status 
  
  before_validation :get_current_cycle_settings
  before_save :set_current_order_cycle_to_complete
  
  def get_current_cycle_settings
    @current_cycle_settings = OrderCycleSetting.first
  end
  
  def set_current_order_cycle_to_complete
    current_order_cycle = current_cycle
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
  
  def save_and_set_status
    if self.start_date > Time.current
      self.status = "pending"
    else
      self.status = "current"
    end
    
    success = self.save
    if success
      complete_pending_cycles
      if self.start_date > Time.current
        OrderCycle.queue_order_cycle_start_job(self.start_date)
      else
        OrderCycle.queue_order_cycle_end_job(self.end_date)
      end
    end
    return success
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

  def complete_pending_cycles
    pending_cycles = OrderCycle.where("status = ?", "pending")
    pending_cycles.each do |cycle|
      cycle.update_column(:status, "complete")
    end
  end
  
  def self.current_cycle
    self.find_by_status("current")
  end
  
  def self.pending_delivery
    self.where("buyer_pickup_date >= ? AND status = ?", DateTime.now.utc, "complete").first
  end
  
  def self.current_cycle_id
    return current_cycle ? current_cycle.id : 0
  end
  
  def self.latest_cycle
    self.where("status != ?", "pending").last
  end
  
  def self.last_ten_cycles
    self.where("status != ?", "pending").last(10)
  end
  
  def self.last_completed
    last_order_cycle_date = self.where(:status => "complete")
                                      .maximum(:end_date)
    last_completed = self.where(:end_date => last_order_cycle_date).last()
    if last_completed
      last_completed
    else
      self.latest_cycle
    end
  end
    
  def self.queue_order_cycle_start_job(start_date)
    job = OrderCycleStartJob.new
    Delayed::Job.where("queue = ? OR queue = ?","order_cycle_end","order_cycle_start").each do |job|
      job.destroy
    end
    Delayed::Job.enqueue(job, 0, start_date, :queue => 'order_cycle_start')
  end
  
  def self.queue_order_cycle_end_job(end_date)
    job = OrderCycleEndJob.new
    Delayed::Job.where("queue = ? OR queue = ?","order_cycle_end","order_cycle_start").each do |job|
      job.destroy
    end
    Delayed::Job.enqueue(job, 0, end_date, :queue => 'order_cycle_end')
  end
end
