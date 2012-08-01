pdf.text "Inbound Delivery Log", :size => 30, :style => :bold

pdf.move_down(30)

items = [["Seller Name", "Buyer Name", "Item Name", "Quantity", "Delivered"]]
@items.map do |item|
items +=  [[
    item.seller_last_name + ", " + item.seller_first_name,
    item.buyer_last_name + ", " + item.buyer_first_name,
    item_name(item.inventory_item),
    "#{item.quantity}#{" "}#{item_quantity_label(item.inventory_item, item.quantity)}",
    text_box("")
  ]]
end

pdf.table items,
  :header => true,
  :column_widths => [125,125,125,75,75]
pdf.move_down(10)