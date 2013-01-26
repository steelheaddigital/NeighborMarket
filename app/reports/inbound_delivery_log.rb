class InboundDeliveryLog < Prawn::Document
  include ApplicationHelper
  
  def to_pdf(inventory_items)
    text "Inbound Delivery Log", :size => 30, :style => :bold

    move_down(30)

    items = [["Seller Name", "Buyer Name", "Item Name", "Quantity", "Delivered"]]
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
      :column_widths => [125,125,125,75,75]
    move_down(10)

    render
  end
  
end