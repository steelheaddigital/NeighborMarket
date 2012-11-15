require 'test_helper'

class SellerControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  def setup
    @user  = users(:approved_seller_user)
    sign_in @user
  end
  
  test "should get index" do
    get :index
    
    assert_response :success
    assert_not_nil assigns(:current_inventory)
    
  end
  
  test "should get current_inventory" do
    get :current_inventory
    
    assert_response :success
    assert_not_nil assigns(:current_inventory)
    
  end
  
  test "should get pick_list" do
    get :pick_list
    
    assert_response :success
    assert_not_nil assigns(:inventory_items)
    
  end
  
  test "should get packing_list" do
    get :packing_list
    
    assert_response :success
    assert_not_nil assigns(:orders)
    
  end
  
  test "should remove items from order" do
    cart_item = cart_items(:one)
    
    assert_difference 'CartItem.count', -1 do
      delete :remove_item_from_order, :cart_item_id => cart_item.id
    end
    
    assert_redirected_to seller_packing_list_url
  end
  
  test "should update cart item when commit param is not delete all items" do
    order = orders(:current)
    cart_item = cart_items(:one)
    
    assert_difference "CartItem.find(#{cart_item.id}).quantity", -1 do
      post :update_order, :order_id => order.id, :order => {:cart_items_attributes => { "0" => {:id => cart_item.id, :quantity => 9 } } }
    end
    
    assert_redirected_to seller_packing_list_url
  end
    
  test "should delete cart items when commit param is delete all items" do
    order = orders(:current)
    cart_item = cart_items(:one)

    assert_difference 'CartItem.count', -order.cart_items.count do
      post :update_order, :order_id => order.id, :commit => "Delete All Items"
    end

    assert_redirected_to seller_packing_list_url
  end
  
  test "anonymous user cannot access protected actions" do
    sign_out @user
    
    get :index
    assert_redirected_to new_user_session_url
    
    get :current_inventory
    assert_redirected_to new_user_session_url
    
    get :pick_list
    assert_redirected_to new_user_session_url
    
    get :packing_list
    assert_redirected_to new_user_session_url
    
    cart_item = cart_items(:one)
    delete :remove_item_from_order, :cart_item_id => cart_item.id
    assert_redirected_to new_user_session_url
    
    order = orders(:current)
    post :update_order, :order_id => order.id
    assert_redirected_to new_user_session_url
    
  end
  
end
