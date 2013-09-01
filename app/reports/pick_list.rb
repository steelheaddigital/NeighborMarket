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

class PickList < Prawn::Document
  include ApplicationHelper
  
  def to_pdf(inventory_items, selected_previous_order_cycle)
    text "Pick List", :size => 30, :style => :bold
    move_down(30)

    items = [["<b>ID</b>", "<b>Name</b>", "<b>Quantity</b>"]]
    inventory_items.map do |item|
    items +=  [[
        item.id,
        item_name(item),
        "#{item.cart_item_quantity_sum(selected_previous_order_cycle.id)}#{" "}#{item_quantity_label(item, item.cart_item_quantity_sum(selected_previous_order_cycle.id))}"
      ]]
    end

    table items,
      :header => true,
      :column_widths => [100,250,100],
      :cell_style => { :inline_format => true }
      
    move_down(10)

    render
  end
  
end