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
    assert_not_nil assigns(:all_inventory)    
  end
  
  test "should get index js" do
    get :index, :format => 'js'
    
    assert_not_nil assigns(:current_inventory)
    assert_not_nil assigns(:all_inventory)   
    assert_equal response.content_type, Mime::JS
  end
  
  test "should get pick_list" do
    get :pick_list
    
    assert_response :success
    assert_not_nil assigns(:inventory_items)
    
  end
  
  test "should get previous_pick_list" do
    order_cycle = order_cycles(:complete)
    get :pick_list, :selected_previous_order_cycle => {:id => order_cycle.id}
    
    assert_response :success
    assert_not_nil assigns(:inventory_items)
    assert_not_nil assigns(:previous_order_cycles)
    assert_not_nil assigns(:selected_previous_order_cycle)
  end
  
  test "should get previous_pick_list pdf" do
    order_cycle = order_cycles(:complete)
    get :pick_list, :selected_previous_order_cycle => {:id => order_cycle.id}, :format => 'pdf'
    
    assert_response :success
    assert_not_nil assigns(:inventory_items)
    assert_not_nil assigns(:previous_order_cycles)
    assert_not_nil assigns(:selected_previous_order_cycle)
    assert_equal response.content_type, "application.pdf"
  end
  
  test "should get packing_list" do
    get :packing_list
    
    assert_response :success
    assert_not_nil assigns(:orders)
    assert_not_nil assigns(:seller)
    assert_not_nil assigns(:previous_order_cycles)
    assert_not_nil assigns(:selected_previous_order_cycle)
  end
  
  test "should get previous_packing_list" do
    order_cycle = order_cycles(:complete)
    get :packing_list, :selected_previous_order_cycle => {:id => order_cycle.id}
    
    assert_response :success
    assert_not_nil assigns(:orders)
    assert_not_nil assigns(:seller)
    assert_not_nil assigns(:previous_order_cycles)
    assert_not_nil assigns(:selected_previous_order_cycle)
  end
  
  test "should get previous_packing_list pdf" do
    order_cycle = order_cycles(:complete)
    get :packing_list, :selected_previous_order_cycle => {:id => order_cycle.id}, :format => 'pdf'
    
    assert_response :success
    assert_not_nil assigns(:orders)
    assert_not_nil assigns(:seller)
    assert_not_nil assigns(:previous_order_cycles)
    assert_not_nil assigns(:selected_previous_order_cycle)
    assert_equal response.content_type, "application.pdf"
  end
  
  test "anonymous user cannot access protected actions" do
    sign_out @user
    
    get :index
    assert_redirected_to new_user_session_path
    
    get :pick_list
    assert_redirected_to new_user_session_path
    
    get :packing_list
    assert_redirected_to new_user_session_path
    
    cart_item = cart_items(:one)
    delete :remove_item_from_order, :cart_item_id => cart_item.id
    assert_redirected_to new_user_session_path
    
  end
  
end
