class PackingList < Prawn::Document
  include ApplicationHelper
  
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
                :text => order.user.address + ", " + order.user.city + ", " + order.user.state + " " + order.user.zip
            }
        ])

        move_down(10)

        items = [["ID", "Name", "Quantity"]]
        order.cart_items.map do |item|
            if item.inventory_item.user_id == seller.id
                items +=  [[
                    item.inventory_item.id,
                    item_name(item.inventory_item),
                    "#{item.quantity}#{" "}#{item_quantity_label(item.inventory_item, item.quantity)}"
                  ]]
            end
        end

        table items,
          :header => true,
          :column_widths => [100,250,100]

        start_new_page
    end

    render
  end
  
end