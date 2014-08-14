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
  has_many :cart_items, :dependent => :destroy
  belongs_to :user
  belongs_to :order_cycle
  
  accepts_nested_attributes_for :cart_items
  attr_accessible :cart_items_attributes, :deliver
  attr_accessor :current_user
  
  validate :ensure_current_order_cycle
  before_validation :set_cart_items_user
  
  before_save do |order|
    if order.order_cycle_id.nil?
      order_cycle_id = OrderCycle.current_cycle_id
      order.order_cycle_id = order_cycle_id
    end
    update_seller_inventory(order)
  end
    
  def add_inventory_items_from_cart(cart)
    cart.cart_items.each do |item|
      item.cart_id = nil
      existing_item = cart_items.find{|x| x.inventory_item_id == item.inventory_item_id}
      if !existing_item.nil?
        existing_item.quantity += item.quantity
      else
        cart_items << item
      end
    end
  end
  
  def cart_items_where_order_cycle_minimum_reached
    #minimum_reached_at_order_cycle_end is always true until the end of the order cycle when it will be changed to false 
    #if the minimum purchase quantity for the inventory item is not reached
    cart_items.select{|cart_item| cart_item.minimum_reached_at_order_cycle_end == true}
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
  
  def total_price
    cart_items_where_order_cycle_minimum_reached.to_a.sum { |item| item.total_price }
  end
  
  def total_price_by_seller(seller_id)
    cart_items_where_order_cycle_minimum_reached.select{ |item| item.inventory_item.user_id == seller_id }
                                                .sum { |item| item.total_price }
  end
  
  def sub_totals
    sub_total = {}
    cart_items_where_order_cycle_minimum_reached.group_by{|item| item.inventory_item.user.id}.each do |key, value| 
      total = value.map{|cart_item| cart_item.total_price}.reduce(:+)
      sub_total[key] = total 
    end
    return sub_total
  end
  
  def eligible_for_delivery?
    !self.user.address.blank? && !self.user.city.blank? && !self.user.state.blank? && !self.user.country.blank? && !self.user.zip.blank? && !self.user.delivery_instructions.blank?
  end
  
  private
  
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
  
  def update_seller_inventory(order)
    order.cart_items.each do |item|
      #if the quantity was changed and the cart_item is part of an order
      if item.quantity_changed? and item.order_id
        difference = item.quantity - item.quantity_was
        item.inventory_item.decrement_quantity_available(difference)
      #this is a new or existing order
      else
        item.inventory_item.decrement_quantity_available(item.quantity)
      end
    end
  end
  
end
