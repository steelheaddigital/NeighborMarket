require 'test_helper'

class CartTest < ActiveSupport::TestCase
   
  test "add_inventory_item adds to quantity if item already in cart" do
   
      cart = Cart.find(1)
      
      result = cart.add_inventory_item(1, 10)
    
      assert_not_nil result
      assert_equal(result.cart_id, 1)
      assert_equal(result.inventory_item_id, 1)
      assert_equal(result.quantity, 20)
    
   end
   
  test "add_inventory_item adds item if not already in cart" do
   
      cart = Cart.find(1)
      
      result = cart.add_inventory_item(2, 10)
    
      assert_not_nil result
      assert_equal(result.inventory_item_id, 2)
      assert_equal(result.quantity, 10)
    
  end
  
  test "add_inventory_item adds item if cart is empty" do
   
      cart = Cart.find(2)
      
      result = cart.add_inventory_item(2, 10)
    
      assert_not_nil result
      assert_equal(result.inventory_item_id, 2)
      assert_equal(result.quantity, 10)
    
  end
  
  test "total_price returns correct result" do
   
      cart = Cart.find(1)  
      cart.add_inventory_item(2, 10)
    
      result = cart.total_price
    
      assert_equal(result.to_s, "200.0")
    
  end
  
end
