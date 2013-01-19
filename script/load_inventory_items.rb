InventoryItem.transaction do
  (1..100).each do |i|
    item = InventoryItem.new(top_level_category_id: 1, second_level_category_id: 1, name: "test-#{i}", price: 2, price_unit: "each", quantity_available: 5, description: "Lorem Ipsum Doler")
    item.order_cycle_id = 1
    item.user_id = 2
    item.save
  end
end
