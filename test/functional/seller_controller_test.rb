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
    assert_not_nil assigns(:last_inventory)
    assert_not_nil assigns(:current_inventory)
    assert_not_nil assigns(:previous_order_cycles)
    assert_not_nil assigns(:selected_previous_order_cycle)
    assert_not_nil assigns(:show_past_inventory_container)
    
  end
  
  test "should get index js" do
    get :index, :format => 'js'
    
    assert_response :success
    assert_not_nil assigns(:last_inventory)
    assert_not_nil assigns(:current_inventory)
    assert_not_nil assigns(:previous_order_cycles)
    assert_not_nil assigns(:selected_previous_order_cycle)
    assert_not_nil assigns(:show_past_inventory_container)
    assert_equal response.content_type, Mime::JS
    
  end
  
  test "should get previous_index" do
    order_cycle = order_cycles(:complete)
    get :index, :selected_previous_order_cycle => {:id => order_cycle.id}
    
    assert_response :success
    assert_not_nil assigns(:last_inventory)
    assert_not_nil assigns(:current_inventory)
    assert_not_nil assigns(:previous_order_cycles)
    assert_not_nil assigns(:selected_previous_order_cycle)
    assert_not_nil assigns(:show_past_inventory_container)
    
  end
  
  test "should get pick_list" do
    get :pick_list
    
    assert_response :success
    assert_not_nil assigns(:inventory_items)
    
  end
  
  test "should get previous_pick_list" do
    order_cycle = order_cycles(:not_current)
    get :pick_list, :selected_previous_order_cycle => {:id => order_cycle.id}
    
    assert_response :success
    assert_not_nil assigns(:inventory_items)
    assert_not_nil assigns(:previous_order_cycles)
    assert_not_nil assigns(:selected_previous_order_cycle)
  end
  
  test "should get previous_pick_list pdf" do
    order_cycle = order_cycles(:not_current)
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
    assert_equal(true, assigns(:can_edit))
  end
  
  test "should get previous_packing_list" do
    order_cycle = order_cycles(:not_current)
    get :packing_list, :selected_previous_order_cycle => {:id => order_cycle.id}
    
    assert_response :success
    assert_not_nil assigns(:orders)
    assert_not_nil assigns(:seller)
    assert_not_nil assigns(:previous_order_cycles)
    assert_not_nil assigns(:selected_previous_order_cycle)
    assert_equal(false, assigns(:can_edit))
  end
  
  test "should get previous_packing_list pdf" do
    order_cycle = order_cycles(:not_current)
    get :packing_list, :selected_previous_order_cycle => {:id => order_cycle.id}, :format => 'pdf'
    
    assert_response :success
    assert_not_nil assigns(:orders)
    assert_not_nil assigns(:seller)
    assert_not_nil assigns(:previous_order_cycles)
    assert_not_nil assigns(:selected_previous_order_cycle)
    assert_equal(false, assigns(:can_edit))
    assert_equal response.content_type, "application.pdf"
  end
  
  test "should remove items from order" do
    cart_item = cart_items(:one)
    
    assert_difference 'CartItem.count', -1 do
      delete :remove_item_from_order, :cart_item_id => cart_item.id
    end
    
    assert_redirected_to packing_list_seller_index_url
  end
  
  test "should update cart item when commit param is not delete all items" do
    order = orders(:current)
    cart_item = cart_items(:one)
    
    assert_difference "CartItem.find(#{cart_item.id}).quantity", -1 do
      post :update_order, :order_id => order.id, :order => {:cart_items_attributes => { "0" => {:id => cart_item.id, :quantity => 9 } } }
    end
    
    assert_redirected_to packing_list_seller_index_url
  end
    
  test "should delete cart items when commit param is delete all items" do
    order = orders(:current)
    cart_item = cart_items(:one)

    assert_difference 'CartItem.count', -order.cart_items.count do
      post :update_order, :order_id => order.id, :commit => "Delete All Items"
    end

    assert_redirected_to packing_list_seller_index_url
  end
  
  test "anonymous user cannot access protected actions" do
    sign_out @user
    
    get :index
    assert_response :not_found
    
    get :pick_list
    assert_response :not_found
    
    get :packing_list
    assert_response :not_found
    
    cart_item = cart_items(:one)
    delete :remove_item_from_order, :cart_item_id => cart_item.id
    assert_response :not_found
    
    order = orders(:current)
    post :update_order, :order_id => order.id
    assert_response :not_found
    
  end
  
end
