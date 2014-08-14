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

class OutboundDeliveryLog < Prawn::Document
  include ApplicationHelper
  
  def to_pdf(orders)
    text "Outbound Delivery Log", :size => 30, :style => :bold

    move_down(30)

    orders.each do |order|
        formatted_text([
            {
                :text => "Order ID: ",
                :styles => [:bold]
            },
            {
                :text => order.id.to_s
            }
        ])

        formatted_text([
            {
                :text => "Buyer Name: ",
                :styles => [:bold]
            },
            {
                :text => order.user.username
            }
        ])

        formatted_text([
            {
                :text => "Order Complete: ",
                :styles => [:bold]
            },
            {
                :text => text_box("")
            }
        ])

        move_down(10)

        items = [["<b>Seller Name</b>", "<b>Item ID</b>", "<b>Item Name</b>", "<b>Quantity</b>"]]
        order.cart_items_where_order_cycle_minimum_reached.sort_by{|cart_item| [cart_item.inventory_item.user.username]}.map do |item|
            items +=  [[
                item.inventory_item.user.username,
                item.inventory_item.id,
                item_name(item.inventory_item),
                "#{item.quantity}#{" "}#{item_quantity_label(item.inventory_item, item.quantity)}"
              ]]
        end

        table items,
          :header => true,
          :column_widths => [200,50,200,60],
          :cell_style => { :inline_format => true }

        start_new_page
    end

    render
  end
  
end