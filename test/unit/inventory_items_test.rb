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
   
   test "should not allow update if price is changed and item is in current cycle and user is not manager" do
     @item.update_attributes("price" => 50)
     
     assert !@item.valid?
   end
   
   test "should allow update if quantity_available is changed" do
     @item.update_attributes("quantity_available" => 50)
     
     assert @item.valid?
   end
   
   test "should allow update if price is changed and item is in current cycle and user is not manager" do
     @item.update_attributes("price" => 50)
     @item.current_user = users(:manager_user)
     
     assert @item.valid?
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
      
      assert_equal 20, sum
   end
   
   test "add_to_order_cycle adds inventory item if order_cycle is not nil" do
     order_cycles(:current).destroy
     top_level_category = top_level_categories(:vegetable)
     second_level_category = second_level_categories(:carrot)
     inventory_item = InventoryItem.new({ :top_level_category_id => top_level_category.id, :second_level_category_id => second_level_category.id, :name => "test", :price => "10.00", :price_unit => "each", :quantity_available => "10", :description => "test"})
     
     assert inventory_item.valid?
     assert_difference "InventoryItem.count" do
       inventory_item.save
     end
     assert order_cycles(:not_current).inventory_items.count > 0
   end
  
   test "add_to_order_cycle adds model error if order_cycle is nil" do
     order_cycles(:current).destroy
     order_cycles(:not_current).destroy
     top_level_category = top_level_categories(:vegetable)
     second_level_category = second_level_categories(:carrot)
     inventory_item = InventoryItem.new({ :top_level_category_id => top_level_category.id, :second_level_category_id => second_level_category.id, :name => "test", :price => "10.00", :price_unit => "each", :quantity_available => "10", :description => "test"})
    
     assert !inventory_item.valid?
     assert_no_difference "InventoryItem.count" do
       inventory_item.save
     end
   end
   
   test "in_current_order_cycle returns true if item is in current order cycle" do
     item = inventory_items(:one)
     result = item.in_current_order_cycle?
     
     assert result
   end
   
   test "can_edit? returns true if user is manager" do
     item = inventory_items(:one)
     item.current_user = users(:manager_user)
     
     assert item.can_edit?
   end
   
   test "can_edit? returns true if user is not manager and inventory_item is in pending order cycle" do
     item = inventory_items(:three)
     item.current_user = users(:approved_seller_user)
     
     assert item.can_edit?
   end
   
   test "can_edit? returns true if user is not manager and inventory_item is not in any orders" do
     item = inventory_items(:not_in_cart)
     item.current_user = users(:approved_seller_user)
     
     assert item.can_edit?
   end
   
   test "can_edit? returns false if user is not manager and item is in order" do
     item = inventory_items(:one)
     item.current_user = users(:approved_seller_user)
     
     assert !item.can_edit?
   end
   
end
