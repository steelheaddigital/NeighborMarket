require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  test "add_inventory_items_from_cart ads items" do
    order = Order.new
    order.user_id = users(:buyer_user).id
    cart = carts(:full)

    assert_difference 'order.cart_items.size' do
      order.add_inventory_items_from_cart(cart)
    end
    assert_not_nil order.cart_items
  end
  
  test "total_price returns correct result" do
      order = orders(:current)
      cart = carts(:full)
      order.add_inventory_items_from_cart(cart)
      result = order.total_price
      assert_equal(result.to_s, "100.0")
  end
  
  test "sub_totals returns correct result" do
      order = orders(:current)
      cart = carts(:full)
      order.add_inventory_items_from_cart(cart)
      result = order.sub_totals
      assert_equal(result.first[1].to_s, "100.0")
  end
  
  test "seller inventory changed by difference in quantity when associated cart item changed" do
    
    order = orders(:current)
    cart_item_id = order.cart_items.first.id
    order.attributes = {:cart_items_attributes => [:id => cart_item_id, :quantity => 9]}
    
    assert_difference 'order.cart_items.first.inventory_item.quantity_available' do
      order.save
    end
  end
  
  test "seller inventory decreased by associated cart item quantity when order exists" do
    
    order = orders(:current)
    cart_item_id = order.cart_items.first.id
    order.attributes = {:cart_items_attributes => [:id => cart_item_id, :quantity => 10]}
    
    assert_difference 'order.cart_items.first.inventory_item.quantity_available', -10 do
      order.save
    end
    
  end
  
  test "seller inventory decreased by associated cart item quantity when new order" do
    
    cart = carts(:full)
    order = Order.new
    order.cart_items = cart.cart_items
    
    assert_difference 'order.cart_items.first.inventory_item.quantity_available', -10 do
      order.save
    end
    
  end
  
  test "seller inventory increased by associated cart item quantity when order destroyed" do
    order = orders(:current)
    inventory_item = order.cart_items.first.inventory_item
    
    assert_difference 'InventoryItem.find(inventory_item.id).quantity_available', 10 do
      order.destroy
    end
    
  end
  
  test "returns validation error if order is not in current order_cycle" do
    order = orders(:not_current)
    
    assert order.invalid?
  end
  
end
