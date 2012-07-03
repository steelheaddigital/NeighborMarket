require 'test_helper'

class CartItemTest < ActiveSupport::TestCase
  test "total price returns correct total price" do
    item = cart_items(:one)
    
    assert_equal item.total_price.to_s, "100.0"
  end
end
