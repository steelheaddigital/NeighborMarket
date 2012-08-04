pdf.text "Inbound Delivery Log", :size => 30, :style => :bold

pdf.move_down(30)

items = [["Seller Name", "Buyer Name", "Item Name", "Quantity", "Delivered"]]
@items.sort_by{|item| [item.inventory_item.user.last_name, item.inventory_item.user.first_name, item.order.user.last_name, item.order.user.first_name]}.map do |item|
items +=  [[
    item.inventory_item.user.last_name + ", " + item.inventory_item.user.first_name,
    item.order.user.last_name + ", " + item.order.user.first_name,
    item_name(item.inventory_item),
    "#{item.quantity}#{" "}#{item_quantity_label(item.inventory_item, item.quantity)}",
    text_box("")
  ]]
end

pdf.table items,
  :header => true,
  :column_widths => [125,125,125,75,75]
pdf.move_down(10)