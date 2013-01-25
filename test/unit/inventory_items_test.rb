require 'test_helper'

class InventoryItemsTest < ActiveSupport::TestCase
  
   def setup
     @item = inventory_items(:one)
   end
  
   test "should not validate item without top level category id" do
      @item.top_level_category_id = nil
      
      assert !@item.valid?
   end
   
   test "should not validate item without second level category id" do
      @item.second_level_category_id = nil
      
      assert !@item.valid?
   end
   
   test "should not validate item without price" do
      @item.price = nil
      
      assert !@item.valid?
   end
   
   test "should not validate item without quanity available" do
      @item.quantity_available = nil
      
      assert !@item.valid?
   end
   
   test "should not validate item with non-numeral price" do
      @item.price = "test"
      
      assert !@item.valid?
   end
   
   test "should not validate item with price less than 0.01" do
      @item.price = 0
      
      assert !@item.valid?
   end
   
   test "should not validate item with quantity available less than 0" do
      @item.quantity_available = -1
      
      assert !@item.valid?
   end
   
   test "should not validate item with non-numeral quantity available" do
      @item.quantity_available = "test"
      
      assert !@item.valid?
   end
   
   test "should not allow destroy if item is in cart" do
      assert !@item.destroy
   end
   
   test "should allow destroy if item is not in cart" do
     item = inventory_items(:not_in_cart)
      
     assert item.destroy
   end
   
   test "decrement_quantity_available decrements quantity available" do
      item = inventory_items(:one)
     
      assert_difference 'item.quantity_available', -2 do
        item.decrement_quantity_available(2)
      end
   end
   
   test "search doesn't return result if quantity_availabe is 0" do
     item = InventoryItem.search("zero")
     
     assert_equal 0, item.length
     
   end
   
   test "paranoid destroy sets is_deleted attribute to true and deletes current cart_items when item has cart_items not in current order cycle" do     
     item = inventory_items(:one)
     cart_item = cart_items(:one)
     item.paranoid_destroy
     
     assert InventoryItem.exists?(item)
     assert !CartItem.exists?(cart_item)
     assert item.is_deleted
   end
   
   test "paranoid destroy destroys item when item has no cart_items in a previous order cycle" do     
     item = inventory_items(:two)
     item.paranoid_destroy
     
     assert !InventoryItem.exists?(item)
   end
   
   test "cart_item_quantity_sum sums cart item quantities" do
      item = inventory_items(:one)
      sum = item.cart_item_quantity_sum
      
      assert_equal 30, sum
   end
end
