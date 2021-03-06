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

module Totalable
  extend ActiveSupport::Concern
  
  def cart_items_where_order_cycle_minimum_reached
    #minimum_reached_at_order_cycle_end is always true until the end of the order cycle when it will be changed to false 
    #if the minimum purchase quantity for the inventory item is not reached
    cart_items.select { |cart_item| cart_item.minimum_reached_at_order_cycle_end == true }
  end

  def online_payment_cart_items
    cart_items.select { |cart_item| cart_item.minimum_reached_at_order_cycle_end == true && cart_item.inventory_item.user.online_payment_processor_configured? == true }
  end

  def in_person_payment_cart_items
    cart_items.select { |cart_item| cart_item.minimum_reached_at_order_cycle_end == true && cart_item.inventory_item.user.online_payment_processor_configured? == false }
  end
  
  def total_price
    cart_items_where_order_cycle_minimum_reached.to_a.sum(&:total_price)
  end
  
  def total_price_by_seller(seller_id)
    cart_items_where_order_cycle_minimum_reached.select { |item| item.inventory_item.user_id == seller_id }.sum(&:total_price)
  end

  def online_payment_total
    online_payment_cart_items.to_a.sum(&:total_price)
  end
  
  def in_person_payment_total
    in_person_payment_cart_items.to_a.sum(&:total_price)
  end

  def sub_totals
    sub_total = {}
    cart_items_where_order_cycle_minimum_reached.group_by { |item| item.inventory_item.user.id }.each do |key, value| 
      total = value.map(&:total_price).reduce(:+)
      sub_total[key] = total 
    end
    sub_total
  end

  def online_payment_sub_totals
    sub_total = {}
    online_payment_cart_items.group_by { |item| item.inventory_item.user.id }.each do |key, value| 
      total = value.map(&:total_price).reduce(:+)
      sub_total[key] = total 
    end
    sub_total
  end

  def in_person_payment_sub_totals
    sub_total = {}
    in_person_payment_cart_items.group_by { |item| item.inventory_item.user.id }.each do |key, value| 
      total = value.map(&:total_price).reduce(:+)
      sub_total[key] = total 
    end
    sub_total
  end
end
