class PickList < Prawn::Document
  include ApplicationHelper
  
  def to_pdf(inventory_items)
    text "Pick List", :size => 30, :style => :bold
    move_down(30)

    items = [["ID", "Name", "Quantity"]]
    inventory_items.map do |item|
    items +=  [[
        item.id,
        item_name(item),
        "#{item.cart_item_quantity_sum}#{" "}#{item_quantity_label(item, item.cart_item_quantity_sum)}"
      ]]
    end

    table items,
      :header => true,
      :column_widths => [100,250,100]
    move_down(10)

    render
  end
  
end