require 'test_helper'

class CartItemTest < ActiveSupport::TestCase
  test "total price returns correct total price" do
    item = cart_items(:one)
    
    assert_equal item.total_price.to_s, "100.0"
  end
  
  test "quantity can't be greater than quantity available" do
    inventory_item = inventory_items(:one)
    item = CartItem.new(:inventory_item_id => inventory_item.id, :quantity => 11)
    
    assert !item.valid?
  end
  
  test "returns validation error if no current order cycle" do
    current_order_cycle = OrderCycle.current_cycle
    current_order_cycle.destroy
    inventory_item = inventory_items(:one)
    item = CartItem.new(:inventory_item_id => inventory_item.id, :quantity => 5)
    
    assert !item.valid?
  end
  
  test "updates inventory_item quantity availabe on destroy if item has order" do
    item = cart_items(:one)
    
    assert_difference "item.inventory_item.quantity_available", item.quantity do
      item.destroy
    end
  end
  
  test "doesn not update inventory_item quantity availabe on destroy if item does not have order" do
    item = cart_items(:no_order)
    
    assert_no_difference "item.inventory_item.quantity_available" do
      item.destroy
    end
  end
  
end
