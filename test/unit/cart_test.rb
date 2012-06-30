require 'test_helper'

class CartTest < ActiveSupport::TestCase
   
  test "add_inventory_item adds to quantity if item already in cart" do
   
      cart = carts(:full)
      item = inventory_items(:one)
      
      result = cart.add_inventory_item(item.id, 10)
    
      assert_not_nil result
      assert_equal(result.quantity, 20)
      assert_equal(result.inventory_item.name, "Carrot")
    
   end
   
  test "add_inventory_item adds item if not already in cart" do
   
      cart = carts(:full)
      item = inventory_items(:two)
      
      result = cart.add_inventory_item(item.id, 10)
    
      assert_not_nil result
      assert_equal(result.quantity, 10)
      assert_equal(result.inventory_item.name, "Jam")
    
  end
  
  test "add_inventory_item adds item if cart is empty" do
   
      cart = carts(:empty)
      item = inventory_items(:two)
      
      result = cart.add_inventory_item(item.id, 10)
    
      assert_not_nil result
      assert_equal(result.quantity, 10)
    
  end
  
  test "total_price returns correct result" do
   
      cart = carts(:full)
      item = inventory_items(:two)
      
      cart.add_inventory_item(item.id, 10)
    
      result = cart.total_price
    
      assert_equal(result.to_s, "200.0")
    
  end
  
end
