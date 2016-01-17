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

class InventoryItemOrderCycle < ActiveRecord::Base
  belongs_to :inventory_item, touch: true
  belongs_to :order_cycle
  
  before_destroy :user_can_delete_from_order_cycle
  
  def user_can_delete_from_order_cycle
    if !inventory_item.can_edit?
      errors.add(:base, "Item cannot be removed from the current order cycle since it is contained in one or more orders. If you need to change this item, please <a href=\"#{Rails.application.routes.url_helpers.new_inventory_item_change_request_path(:inventory_item_id => self.inventory_item_id)}\">send a request</a> to the site manager.".html_safe)
      return false
    end
  end
  
end
