InventoryItem.transaction do
  (1..100).each do |i|
    InventoryItem.create(top_level_category_id: 1, second_level_category_id: 1, user_id: 2, name: "test-#{i}", price: 2, price_unit: "each", quantity_available: 5, description: "Lorem Ipsum Doler")
  end
end
