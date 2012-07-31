pdf.text "Packing List", :size => 30, :style => :bold

pdf.move_down(30)

@orders.each do |order|
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

    pdf.move_down(10)

    items = [["ID", "Name", "Quantity"]]
    order.cart_items.map do |item|
        if item.inventory_item.user_id == current_user.id
            items +=  [[
                item.inventory_item.id,
                item_name(item.inventory_item),
                item.quantity
              ]]
        end
    end

    pdf.table items,
      :header => true,
      :column_widths => [100,250,100]

    pdf.start_new_page
end
