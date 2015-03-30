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

class CartItem < ActiveRecord::Base
  belongs_to :cart
  belongs_to :inventory_item
  belongs_to :order
  
  attr_accessible :inventory_item_id, :quantity
  attr_accessor :current_user
  
  validate :validate_quantity,
           :ensure_current_order_cycle
           
  validate :validate_can_edit, :on => :update
  
  before_destroy :update_inventory_item_quantities
  after_destroy :check_order
  
  def can_edit?
    user_editable || self.order.nil?
  end
  
  def update_inventory_item_quantities
    self.inventory_item.increment_quantity_available(self.quantity) if self.order
  end
  
  def total_price
    inventory_item.price * quantity
  end
  
  private
  
  def validate_can_edit
    if !can_edit?
      if self.quantity_was > self.quantity && self.cart.nil?
        errors.add(:quantity, "cannot be decreased after your order has been completed. If you need to change this item, please <a href=\"#{Rails.application.routes.url_helpers.new_order_change_request_path(:order_id => self.order.id)}\">send a request</a> to the site manager.".html_safe)
      end
    end
  end
  
  def user_editable
    if current_user
      @user_editable = current_user.manager?
    end
    @user_editable || false
  end
  
  def check_order
    if self.order
      self.order.destroy if self.order.cart_items.count == 0 && !self.order.destroyed? && !self.order.will_destroy?
    end
  end
  
  def validate_quantity
    inventory_item.reload
    if !self.order_id.nil?
      if (inventory_item.quantity_available + self.quantity_was) - self.quantity < 0
        errors.add(:quantity, "cannot be greater than quantity available of #{inventory_item.quantity_available + self.quantity_was} for item #{inventory_item.name}")
      end
    else
      if inventory_item.quantity_available - self.quantity < 0
        errors.add(:quantity, "cannot be greater than quantity available of #{inventory_item.quantity_available} for item #{inventory_item.name}")
      end
    end
  end
  
  def ensure_current_order_cycle
    if !OrderCycle.current_cycle
      errors.add("","there is no open order cycle at this time.  Please check back later.")
    end
  end
  
end