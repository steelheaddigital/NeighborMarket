require 'test_helper'

class InventoryItemChangeRequestControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  def setup
    @user  = users(:approved_seller_user)
    sign_in @user
  end
  
  test "should get change_request" do
    item = inventory_items(:one)
    get :new, :inventory_item_id => item.id
    
    assert_response :success
    assert_not_nil assigns(:item)
    assert_not_nil assigns(:request)
  end
  
  test "should send_change_request" do
    item = inventory_items(:one)
    post :create, {:inventory_item_id => item.id, :inventory_item_change_request => {:description => "Test Description"} }
    
    assert_not_nil assigns(:item)
    assert_not_nil assigns(:request)
    assert_equal "Test Description", assigns(:request).description
    assert_equal item, assigns(:request).inventory_item
    assert_redirected_to seller_index_path
  end
  
  test "anonymous user cannot access protected actions" do
    sign_out @user
    item = inventory_items(:one)
    
    get :new, :inventory_item_id => item.id
    assert_redirected_to new_user_session_path
    
    post :create, :inventory_item_id => item.id
    assert_redirected_to new_user_session_path
    
  end
end