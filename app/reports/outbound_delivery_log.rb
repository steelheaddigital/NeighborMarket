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
        order.cart_items.sort_by{|cart_item| [cart_item.inventory_item.user.username]}.map do |item|
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