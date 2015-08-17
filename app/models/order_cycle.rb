#
#Copyright 2013 Neighbor Market
#
#This file is part of Neighbor Market.
#
#Neighbor Market is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#Neighbor Market is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with Neighbor Market.  If not, see <http://www.gnu.org/licenses/>.
#

require_relative '../../lib/order_cycle_end_job'
require_relative '../../lib/order_cycle_start_job'
require 'sidekiq/api'

class OrderCycle < ActiveRecord::Base
  has_many :orders
  has_many :inventory_item_order_cycles
  has_many :inventory_items, -> { uniq }, :through => :inventory_item_order_cycles
  validate :end_date_not_before_today,
           :end_date_not_before_start_date,
           :seller_delivery_date_not_before_end_date,
           :buyer_pickup_date_not_before_seller_delivery_date,
           :next_end_date_not_before_next_start_date,
           :next_end_date_not_before_now
  
  attr_accessible :start_date, :end_date, :status, :seller_delivery_date, :buyer_pickup_date, :status 
  attr_accessor :updating
  
  before_validation :get_current_cycle_settings
  before_save :set_current_order_cycle_to_complete, unless: :updating
  
  def self.get_order_cycle
    if find_by_status('current')
      order_cycle = find_by_status('current')
    elsif find_by_status('pending')
      order_cycle = find_by_status('pending')
    else
      order_cycle = new
    end

    order_cycle
  end
  
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
    order_cycle = new(order_cycle_params)
    order_cycle.set_order_cycle_end_date(order_cycle_settings)
    
    order_cycle
  end
  
  def self.update_current_order_cycle(order_cycle_params, order_cycle_settings)
    order_cycle = get_order_cycle
    order_cycle.assign_attributes(order_cycle_params)
    order_cycle.set_order_cycle_end_date(order_cycle_settings)
    order_cycle.updating = true unless order_cycle.id.nil?
    
    order_cycle
  end
  
  def set_order_cycle_end_date(settings)
    if settings.recurring
      interval = settings.interval.pluralize.to_sym
      self.end_date = start_date.advance(interval => 1)
    end
  end
  
  def save_and_set_status
    if start_date > Time.current
      self.status = 'pending'
    else
      self.status = 'current'
    end
    
    success = save
    if success
      #complete_pending_cycles
      if start_date > Time.current
        OrderCycle.queue_order_cycle_start_job(start_date)
      else
        #post new inventory items marked as auto-post
        InventoryItem.autopost(self) unless updating
        OrderCycle.queue_order_cycle_end_job(end_date)
        sellers = User.joins(:roles, :user_preference).where(roles: { name: 'seller' }, user_preferences: { seller_new_order_cycle_notification: true })
        sellers.each do |seller|
          seller.save if seller.authentication_token.blank? #generate an auth token
          SellerMailer.delay.order_cycle_start_mail(seller, self)
        end
      end
    end
    success
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
        errors.add(:end_date, 'of ' + next_end_date.strftime("%m/%d/%Y %I:%M %p") + ' cannot be before the next calculated start date of ' + next_start_date.strftime("%m/%d/%Y %I:%M %p") + '. Check the value of Padding.')
      end
    end
  end
  
  def next_end_date_not_before_now
    if @current_cycle_settings.recurring
      next_end_date = end_date.advance(@current_cycle_settings.interval.pluralize.to_sym => 2)
      if next_end_date.to_datetime < DateTime.current
        errors.add(:end_date, 'of ' + next_end_date.strftime("%m/%d/%Y %I:%M %p") + ' cannot be today')
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
    find_by_status("current")
  end
  
  def self.pending_delivery
    where("buyer_pickup_date >= ? AND status = ?", DateTime.now.utc, "complete").first
  end
  
  def self.current_cycle_id
    current_cycle ? current_cycle.id : 0
  end
  
  def self.latest_cycle
    where("status != ?", "pending").last
  end
  
  def self.last_ten_cycles
    where("status != ?", "pending").last(10)
  end
  
  def self.last_completed
    last_order_cycle_date = where(status: 'complete')
                            .maximum(:end_date)
    last_completed = where(end_date: last_order_cycle_date).last
    if last_completed
      last_completed
    else
      latest_cycle
    end
  end
  
  def self.active_cycle
    where("status IN('pending', 'current')").last
  end
    
  def self.queue_order_cycle_start_job(start_date)
    scheduled_set = Sidekiq::ScheduledSet.new
    jobs = scheduled_set.select { |ss| ss.klass == 'OrderCycleStartJob' || ss.klass == 'OrderCycleEndJob' }
    jobs.each(&:delete)
    OrderCycleStartJob.perform_at(start_date)
  end

  def self.queue_order_cycle_end_job(end_date)
    scheduled_set = Sidekiq::ScheduledSet.new
    jobs = scheduled_set.select { |ss| ss.klass == 'OrderCycleStartJob' || ss.klass == 'OrderCycleEndJob' || ss.klass == 'PostPickupJob' }
    jobs.each(&:delete)
    OrderCycleEndJob.perform_at(end_date)
  end
  
end
