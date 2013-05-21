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

class BuyerInvoices < Prawn::Document
  include ApplicationHelper
  include ActionView::Helpers::NumberHelper
  
  def to_pdf(orders)
    text "Buyer Invoices", :size => 30, :style => :bold

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
                :text => "Buyer Address: ",
                :styles => [:bold]
            },
            {
                :text => order.user.address + ", " + order.user.city + ", " + order.user.state + " " + order.user.zip
            }
        ])

        formatted_text([
            {
                :text => "Delivery Instructions: ",
                :styles => [:bold]
            },
            {
                :text => order.user.delivery_instructions
            }
        ])

        move_down(10)

        items = [["<b>Seller Name</b>", "<b>Item ID</b>", "<b>Item Name</b>", "<b>Quantity</b>", "<b>Price</b>", "<b>Total Price</b>"]]
        order.sub_totals.each do |key, value|
          seller_name = ""
          order.cart_items.select{|i| i.inventory_item.user.id == key}.each do |item|
            seller_name = item.inventory_item.user.username
              items +=  [[
                  item.inventory_item.user.username,
                  item.inventory_item.id,
                  item_name(item.inventory_item),
                  item.quantity.to_s + " " + item_quantity_label(item.inventory_item, item.quantity).to_s,
                  number_to_currency(item.inventory_item.price).to_s + " " + price_unit_label(item.inventory_item),
                  number_to_currency(item.total_price).to_s
                ]]
              end
              items += [[
                "",
                "",
                "",
                "",
                "<b>Subtotal for " + seller_name + "</b>",
                number_to_currency(value)
              ]]
        end
        items += [[
          "",
          "",
          "",
          "",
          "<b>Grand total:</b>",
          number_to_currency(order.total_price)
        ]]

        table items,
          :header => true,
          :column_widths => [100,50,110,85,125,60],
          :cell_style => { :inline_format => true }

        start_new_page
    end

    render
  end
  
end