require 'test_helper'

class CartItemsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  test "should create cart item" do
    inventory_item = inventory_items(:one)
    
    assert_difference 'CartItem.count' do
      post :create,  :quantity => '10', :inventory_item_id => inventory_item.id 
    end
    
    assert_not_nil assigns(:cart)
    assert_not_nil assigns(:cart_item)
    assert_redirected_to cart_index_path
  end
  
  test "should destroy cart item" do
    cart_item = cart_items(:one)
    
    assert_difference 'CartItem.count', -1 do
      get :destroy,  :cart_item_id => cart_item.id 
    end
    
    assert_not_nil assigns(:cart_item)
    assert_redirected_to cart_index_path
  end
end
