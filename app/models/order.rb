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

class Order < ActiveRecord::Base
  include Totalable
  include PaymentProcessor
  include Payable
  
  has_many :cart_items, dependent: :destroy, autosave: true
  belongs_to :user
  belongs_to :order_cycle
  has_many :payments
  
  accepts_nested_attributes_for :cart_items
  attr_accessible :cart_items_attributes, :deliver
  attr_accessor :current_user, :paying_online
  
  validate :ensure_current_order_cycle
  
  before_validation :set_cart_items_user

  before_save :update_order_cycle_id, 
              :update_seller_inventory_and_process_refunds,
              :set_in_person_payments_completed
  after_commit :disassociate_cart_items_from_cart
  
  scope :active, -> { where(canceled: false) }

  def self.update_or_new(cart)
    user = cart.user
    current_order = user.current_order

    if current_order
      order = current_order
    else
      order = user.orders.build
    end
    order.add_inventory_items_from_cart(cart)
    
    order
  end

  def add_inventory_items_from_cart(cart)
    cart.cart_items.each do |item|
      existing_item = cart_items.find { |x| x.inventory_item_id == item.inventory_item_id }
      if !existing_item.nil?
        if item.order_id.nil?
          existing_item.quantity += item.quantity
        else
          existing_item.quantity = item.quantity
        end
      else
        cart_items << item
      end
    end
  end
  
  def purchase(cart, params)
    ActiveRecord::Base.transaction do
      begin
        save
        if PaymentProcessorSetting.current_processor_type != 'InPerson' && (cart.items_with_in_person_payment_only? || !paid_online?)
          #using online payment processor but some or all payments are in person
          in_person_redirect_url = in_person_payment_processor.purchase(self, cart, params)
          if paid_online? 
            payment_processor.purchase(self, cart, params)
          else
            in_person_redirect_url
          end
        else
          #call the configured payment processor, could be online or in-person
          payment_processor.purchase(self, cart, params)
        end
      rescue PaymentProcessor::PaymentError => e
        errors.add(:base, e.message)
        raise ActiveRecord::Rollback, e.message
      end
    end
  rescue ActiveRecord::RecordNotSaved
    false
  end
  
  def has_cart_items_where_order_cycle_minimum_not_reached?
    cart_items.where(minimum_reached_at_order_cycle_end: false).any?
  end
  
  def has_cart_items_where_order_cycle_minimum_reached?
    cart_items.where(minimum_reached_at_order_cycle_end: true).any?
  end
  
  def has_items_with_minimum?
    cart_items.any? { |cart_item| cart_item.inventory_item.has_minimum? && !cart_item.inventory_item.minimum_reached? && cart_item.minimum_reached_at_order_cycle_end }
  end
  
  def eligible_for_delivery?
    !user.address.blank? && !user.city.blank? && !user.state.blank? && !user.country.blank? && !user.zip.blank? && !user.delivery_instructions.blank?
  end
  
  def will_cancel?
    @will_cancel
  end

  def cancel
    ActiveRecord::Base.transaction do
      begin
        @will_cancel = true
        self.canceled = true
        save

        payments.where(payment_type: 'pay').find_each(&:refund_all)

        cart_items.each do |item|
          item.inventory_item.increment_quantity_available(item.quantity)
        end
      rescue PaymentProcessor::PaymentError => e
        errors.add(:base, e.message)
        raise ActiveRecord::Rollback, e.message
      end
    end
  rescue ActiveRecord::RecordNotSaved
    false
  end

  def paid_online?
    paying_online == 'true' || payments.any? { |p| p.processor_type != 'InPerson' }
  end

  def paid_in_person?
    payments.any? { |p| p.processor_type == 'InPerson' }
  end

  private

  def will_destroy
    @will_cancel = true
  end
  
  def set_cart_items_user
    cart_items.each do |item|
      item.current_user = current_user
    end
  end
  
  def ensure_current_order_cycle
    current_order_cycle_id = OrderCycle.current_cycle_id
    if order_cycle
      if order_cycle.id != current_order_cycle_id
        errors.add('', 'Order is not in the current open order cycle and cannot be edited')
      end
    end
  end
  
  def update_order_cycle_id
    if order_cycle_id.nil?
      current_order_cycle_id = OrderCycle.current_cycle_id
      self.order_cycle_id = current_order_cycle_id
    end
  end
  
  def update_seller_inventory_and_process_refunds
    cart_items.each do |item|
      #if the quantity was changed and the cart_item is part of an order
      if !item.order_id.nil?
        if item.quantity_changed?
          difference = item.quantity - item.quantity_was
          
          item.inventory_item.decrement_quantity_available(difference)

          if difference < 0
            seller_id = item.inventory_item.user_id
            payment = payments.find_by(receiver_id: seller_id)
            refund_amount = difference.abs * item.price
            payment.refund(refund_amount)
          end
        end
      #this is a new order
      else
        item.inventory_item.decrement_quantity_available(item.quantity)
      end
    end
  rescue PaymentProcessor::PaymentError => e
    errors.add(:base, e.message)
    raise ActiveRecord::Rollback, e.message
  end

  def disassociate_cart_items_from_cart
    cart_items.each do |item|
      item.cart_id = nil
      item.save
    end
  end
  
  def set_in_person_payments_completed
    return unless complete_changed?
    if complete_was == false && complete == true
      payments.where(processor_type: 'InPerson').update_all(status: 'Completed', payment_date: DateTime.now)
    else
      payments.where(processor_type: 'InPerson').update_all(status: 'Pending', payment_date: nil)
    end
  end
end
