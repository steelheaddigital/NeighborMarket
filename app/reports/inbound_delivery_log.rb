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

class InboundDeliveryLog < Prawn::Document
  include ApplicationHelper
  
  def to_pdf(inventory_items)
    text "Inbound Delivery Log", :size => 30, :style => :bold

    move_down(30)

    items = [["<b>Seller Name</b>", "<b>Buyer Name</b>", "<b>Item Name</b>", "<b>Quantity</b>", "<b>Delivered</b>"]]
    inventory_items.sort_by{|item| [item.inventory_item.user.username, item.order.user.username]}.map do |item|
    items +=  [[
        item.inventory_item.user.username,
        item.order.user.username,
        item_name(item.inventory_item),
        "#{item.quantity}#{" "}#{item_quantity_label(item.inventory_item, item.quantity)}",
        text_box("")
      ]]
    end

    table items,
      :header => true,
      :column_widths => [125,125,125,75,75],
      :cell_style => { :inline_format => true }
      
    move_down(10)

    render
  end
  
end