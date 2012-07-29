pdf.text "Inbound Delivery Log", :size => 30, :style => :bold

pdf.move_down(30)

items = [["Seller Name", "Buyer Name", "Item Name", "Delivered"]]
@items.map do |item|
items +=  [[
    item.seller_last_name + ", " + item.seller_first_name,
    item.buyer_last_name + ", " + item.buyer_first_name,
    item_name(item.inventory_item),
    text_box("")
  ]]
end

pdf.table items,
  :header => true,
  :column_widths => [150,150,150,75]
pdf.move_down(10)