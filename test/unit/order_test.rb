require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  test "add_inventory_items_from_cart ads items" do
    order = Order.new
    order.user_id = users(:buyer_user).id
    cart = carts(:full)

#    assert_difference 'order.cart_items.count' do
      order.add_inventory_items_from_cart(cart)
#    end

    assert_not_nil order.cart_items
    
  end
end
