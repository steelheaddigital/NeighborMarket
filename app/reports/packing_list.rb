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

class PackingList < Prawn::Document
  include ApplicationHelper
  include ActionView::Helpers::NumberHelper
  
  def to_pdf(orders, seller)
    text "Packing List", :size => 30, :style => :bold
    move_down(30)

    orders.each do |order|
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
                :text => "Buyer Address: ",
                :styles => [:bold]
            },
            {
                :text => "#{buyer_address(order.user)}"
            }
        ])

        move_down(10)

        items = [["<b>ID</b>", "<b>Name</b>", "<b>Quantity</b>", "<b>Price</b>", "<b>Total Price</b>"]]
        order.cart_items.map do |item|
            if item.inventory_item.user_id == seller.id
                items +=  [[
                    item.inventory_item.id,
                    item_name(item.inventory_item),
                    "#{item.quantity}#{" "}#{item_quantity_label(item.inventory_item, item.quantity)}",
                    number_to_currency(item.inventory_item.price).to_s + " " + price_unit_label(item.inventory_item),
                    number_to_currency(item.total_price).to_s
                  ]]
            end
        end
        items += [[
          "",
          "",
          "",
          "<b>Total:</b>",
          number_to_currency(order.total_price).to_s
        ]]

        table items,
          :header => true,
          :column_widths => [50,135,110,150,85],
          :cell_style => { :inline_format => true }

        start_new_page
    end

    render
  end
  
end