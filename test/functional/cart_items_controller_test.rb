require 'test_helper'

class CartItemsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
    
  test "should create cart item" do
    inventory_item = inventory_items(:one)
    
    assert_difference 'CartItem.count' do
      post :create, :quantity => '10', :inventory_item_id => inventory_item.id 
    end
    
    assert_not_nil assigns(:cart)
    assert_not_nil assigns(:cart_item)
    assert_redirected_to cart_index_path
  end
  
  test "logged in buyer can destroy cart item that is in order" do
    cart_item = cart_items(:one)
    @user = users(:buyer_user)
    sign_in @user
    
    assert_difference 'CartItem.count', -1 do
      get :destroy, :cart_item_id => cart_item.id 
    end
    
    assert_not_nil assigns(:cart_item)
    assert_redirected_to edit_order_path(cart_item.order_id)
  end
  
  test "logged in buyer can destroy cart item that is in cart" do
    cart = carts(:no_order)
    cart_item = cart_items(:no_order)
    @user = users(:buyer_user)
    sign_in @user
    
    assert_difference 'CartItem.count', -1 do
      get(:destroy, { 'cart_item_id' => cart_item.id }, {'cart_id' => cart.id})
    end
    
    assert_not_nil assigns(:cart_item)
    assert_redirected_to cart_index_path
  end
  
  test "anonymous user can destroy cart item if in their session" do
    cart = carts(:no_order)
    cart_item = cart_items(:no_order)
    
    assert_difference 'CartItem.count', -1 do
      get(:destroy, { 'cart_item_id' => cart_item.id }, {'cart_id' => cart.id})
    end
    
    assert_not_nil assigns(:cart_item)
    assert_redirected_to cart_index_path
  end
  
  test "anonymous user cannot access protected actions" do
    
    item = cart_items(:one)
    get :destroy, :cart_item_id => item.id
    assert_response :not_found
    
  end
  
end
