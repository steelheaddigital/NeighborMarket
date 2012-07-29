pdf.text "Pick List", :size => 30, :style => :bold

pdf.move_down(30)

items = [["ID", "Name", "Quantity"]]
@inventory_items.map do |item|
items +=  [[
    item.id,
    item_name(item),
    item.sum
  ]]
end

pdf.table items,
  :header => true,
  :column_widths => [100,250,100]
pdf.move_down(10)