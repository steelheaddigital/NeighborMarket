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
  include Totals
  
  has_many :cart_items, dependent: :destroy, autosave: true
  belongs_to :user
  belongs_to :order_cycle
  has_many :payments, dependent: :destroy
  
  accepts_nested_attributes_for :cart_items
  attr_accessible :cart_items_attributes, :deliver
  attr_accessor :current_user
  
  validate :ensure_current_order_cycle
  
  before_validation :set_cart_items_user

  before_destroy :will_destroy, prepend: true
  before_save :update_order_cycle_id, 
              :update_seller_inventory
  after_save :disassociate_cart_items_from_cart
  
  def add_inventory_items_from_cart(cart)
    cart.cart_items.each do |item|
      existing_item = self.cart_items.find{|x| x.inventory_item_id == item.inventory_item_id}
      if !existing_item.nil?
        if item.order_id.nil?
          existing_item.quantity += item.quantity
        else
          existing_item.quantity = item.quantity
        end
      else
        self.cart_items << item
      end
    end
  end
  
  
  def has_cart_items_where_order_cycle_minimum_not_reached?
    cart_items.where(minimum_reached_at_order_cycle_end: false).any?
  end
  
  def has_cart_items_where_order_cycle_minimum_reached?
    cart_items.where(minimum_reached_at_order_cycle_end: true).any?
  end
  
  def has_items_with_minimum?
    cart_items.any?{|cart_item| cart_item.inventory_item.has_minimum? && !cart_item.inventory_item.minimum_reached? && cart_item.minimum_reached_at_order_cycle_end}
  end
  
  def eligible_for_delivery?
    !self.user.address.blank? && !self.user.city.blank? && !self.user.state.blank? && !self.user.country.blank? && !self.user.zip.blank? && !self.user.delivery_instructions.blank?
  end
  
  def will_destroy?
    @will_destroy
  end
  
  def process_payment(gateway)
    if gateway == "paypal"
      sub_totals.each do |subtotal| {
        seller = User.find(subtotal.key)
        payments.create!(receiver_id: seller.id, payer_id: self.user.id, payment_gross: subtotal.value)
      }
    end
    return true
  rescue
    return false
  end
  
  private
  
  def will_destroy
    @will_destroy = true
  end
  
  def set_cart_items_user
    self.cart_items.each do |item|
      item.current_user = self.current_user
    end
  end
  
  def ensure_current_order_cycle
    current_order_cycle_id = OrderCycle.current_cycle_id
    if order_cycle
      if order_cycle.id != current_order_cycle_id
        errors.add("","Order is not in the current open order cycle and cannot be edited")
      end
    end
  end
  
  def update_order_cycle_id
    if self.order_cycle_id.nil?
      current_order_cycle_id = OrderCycle.current_cycle_id
      self.order_cycle_id = current_order_cycle_id
    end
  end
  
  def update_seller_inventory
    self.cart_items.each do |item|
      #if the quantity was changed and the cart_item is part of an order
      if !item.order_id.nil?
        if item.quantity_changed?
          difference = item.quantity - item.quantity_was
          item.inventory_item.decrement_quantity_available(difference)
        end
      #this is a new order
      else
        item.inventory_item.decrement_quantity_available(item.quantity)
      end
    end
  end
  
  def disassociate_cart_items_from_cart
    self.cart_items.each do |item|
      item.cart_id = nil
      item.save
    end
  end
  
end
