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

class Cart < ActiveRecord::Base
  include Totalable
  
  has_many :cart_items, autosave: true, dependent: :destroy
  belongs_to :user
  accepts_nested_attributes_for :cart_items
  attr_accessible :user_id, :cart_items_attributes
  
  validate :validate_cart_items
  
  def add_inventory_item(inventory_item_id, quantity)
    current_item = cart_items.find_by(inventory_item_id: inventory_item_id)
    inventory_item = InventoryItem.find(inventory_item_id)
    
    if current_item
      current_item.quantity += quantity.to_i
    else
      current_item = cart_items.build(inventory_item_id: inventory_item_id, quantity: quantity.to_i, price: inventory_item.price)
      current_item.cart_id = id
    end
     
    current_item
  end
  
  def total_price
    cart_items.to_a.sum(&:total_price)
  end
  
  def has_items_with_minimum?
    cart_items.any? { |cart_item| cart_item.inventory_item.has_minimum? && !cart_item.inventory_item.minimum_reached? && cart_item.minimum_reached_at_order_cycle_end }
  end
  
  private
  
  def validate_cart_items
    cart_items.each do |cart_item|
      next unless !cart_item.changed? && cart_item.invalid?
      cart_item.errors.full_messages.each do |message|
        errors[:base] << message
      end
    end
  end
  
end
