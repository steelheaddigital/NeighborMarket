require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  test "add_inventory_items_from_cart adds items to new order" do
    order = Order.new
    order.user_id = users(:buyer_user).id
    cart = carts(:full)

    assert_difference 'order.cart_items.size', 2 do
      order.add_inventory_items_from_cart(cart)
    end
    assert_not_nil order.cart_items
  end
  
  test "add_inventory_items_from_cart adds quantity to existing item in order" do
    order = orders(:current)
    order.user_id = users(:buyer_user).id
    cart = carts(:full)
    inventory_item = inventory_items(:one)

    assert_no_difference 'order.cart_items.size' do
      order.add_inventory_items_from_cart(cart)
    end
    assert_not_nil order.cart_items
    assert_equal(20, order.cart_items.find{|x| x.inventory_item_id == inventory_item.id}.quantity)
  end
  
  test "total_price returns correct result" do
      order = Order.new
      cart = carts(:full)
      order.add_inventory_items_from_cart(cart)
      result = order.total_price
      assert_equal(result.to_s, "200.0")
  end
  
  test "total_price_by_seller returns correct result" do
      order = Order.new
      cart = carts(:buyer_not_current)
      seller = users(:approved_seller_user)
      order.add_inventory_items_from_cart(cart)
      result = order.total_price_by_seller(seller.id)
      assert_equal(result.to_s, "100.0")
  end
  
  test "sub_totals returns correct result" do
      order = Order.new
      cart = carts(:full)
      order.add_inventory_items_from_cart(cart)
      result = order.sub_totals
      assert_equal(result.first[1].to_s, "200.0")
  end
  
  test "seller inventory changed by difference in quantity when associated cart item changed" do
    
    order = orders(:current)
    order.current_user = users(:manager_user)
    cart_item_id = order.cart_items.first.id
    order.attributes = {:cart_items_attributes => [:id => cart_item_id, :quantity => 9]}
    
    assert_difference 'order.cart_items.find(cart_item_id).inventory_item.quantity_available' do
      order.save
    end
  end
  
  test "seller inventory decreased by associated cart item quantity when order exists" do
    
    order = orders(:current)
    cart_item_id = order.cart_items.first.id
    order.attributes = {:cart_items_attributes => [:id => cart_item_id, :quantity => 10]}
    
    assert_difference 'order.cart_items.find(cart_item_id).inventory_item.quantity_available', -10 do
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
  
  test "cart_items_where_order_cycle_minimum_reached returns cart items where minimum reached" do
    order = orders(:current_two)
    
    assert_equal 1, order.cart_items_where_order_cycle_minimum_reached.count
  end
  
  test "has_cart_items_where_order_cycle_minimum_not_reached? returns true if order contains cart items where minimum is not reached" do
    order = orders(:current_two)
    
    assert order.has_cart_items_where_order_cycle_minimum_not_reached?
  end
  
  test "has_cart_items_where_order_cycle_minimum_reached returns true if order contains does not contain cart items where minimum is not reached" do
    order = orders(:current)
    
    assert order.has_cart_items_where_order_cycle_minimum_reached?
  end
  
  test "has_items_with_minimum? returns true if order contains contains inventory items with a minimum" do
    order = orders(:current)
    
    assert order.has_items_with_minimum?
  end
end
