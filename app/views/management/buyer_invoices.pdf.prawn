pdf.text "Buyer Invoices", :size => 30, :style => :bold

pdf.move_down(30)

@orders.each do |order|
    pdf.formatted_text([
        {
            :text => "Order ID: ",
            :styles => [:bold]
        },
        {
            :text => order.id.to_s
        }
    ])

    pdf.formatted_text([
        {
            :text => "Buyer Name: ",
            :styles => [:bold]
        },
        {
            :text => order.user.first_name + " " + order.user.last_name
        }
    ])

    pdf.formatted_text([
        {
            :text => "Buyer Address: ",
            :styles => [:bold]
        },
        {
            :text => order.user.address + ", " + order.user.city + ", " + order.user.state + " " + order.user.zip
        }
    ])

    pdf.formatted_text([
        {
            :text => "Delivery Instructions: ",
            :styles => [:bold]
        },
        {
            :text => order.user.delivery_instructions
        }
    ])


    pdf.move_down(10)

    items = [["Seller Name", "Item ID", "Item Name", "Quantity"]]
    order.cart_items.sort_by{|cart_item| [cart_item.inventory_item.user.last_name, cart_item.inventory_item.user.first_name]}.map do |item|
        items +=  [[
            item.inventory_item.user.last_name + " " + item.inventory_item.user.first_name,
            item.inventory_item.id,
            item_name(item.inventory_item),
            "#{item.quantity}#{" "}#{item_quantity_label(item.inventory_item, item.quantity)}"
          ]]
    end

    pdf.table items,
      :header => true,
      :column_widths => [200,50,200,60]

    pdf.start_new_page
end
