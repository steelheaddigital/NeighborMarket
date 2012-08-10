require 'test_helper'

class ManagementControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  def setup
    @user  = users(:manager_user)
    sign_in @user
  end
  
  test "should get index" do
    get :index
    
    assert_response :success
  end
  
  test "should get approve_sellers" do
    get :approve_sellers
    
    assert_response :success
    assert_not_nil assigns(:sellers)
  end
  
  test "should get user_search" do
    get :user_search
    
    assert_response :success
  end
  
  test "should get user_search_results" do
    get :user_search_results, :keywords => 'manager'
    
    assert_response :success
    assert_not_nil assigns (:users)
  end
  
  test "should get categories" do
    get :categories
    
    assert_response :success
    assert_not_nil assigns (:categories)
  end
  
  test "should get inbound_delivery_log" do
    get :inbound_delivery_log
    
    assert_response :success
    assert_not_nil assigns (:items)
  end
  
  test "should update inbound delivery log" do
    cart_item = cart_items(:one)
    post :save_inbound_delivery_log, :cart_items => {"0" => {:id => cart_item.id, :delivered => "true"}}
    
    assert_redirected_to management_inbound_delivery_log_path
    assert_equal(true, cart_item.reload.delivered) 
  end
  
  test "should get outbound_delivery_log" do
    get :outbound_delivery_log
    
    assert_response :success
    assert_not_nil assigns (:orders)
  end
  
  test "should update outbound delivery log" do
    order = orders(:one)
    post :save_outbound_delivery_log, :orders => {"0" => {:id => order.id, :complete => "true"}}
    
    assert_redirected_to management_outbound_delivery_log_path
    assert_equal(true, order.reload.complete) 
  end
  
  test "should get buyer_invoices" do
    get :buyer_invoices
    
    assert_response :success
    assert_not_nil assigns (:orders)
  end
  
  test "anonymous user cannot access protected actions" do
    sign_out @user
    
    get :index
    assert_redirected_to new_user_session_url
    
    get :approve_sellers
    assert_redirected_to new_user_session_url
    
    get :user_search
    assert_redirected_to new_user_session_url
    
    get :user_search_results
    assert_redirected_to new_user_session_url
    
    get :categories
    assert_redirected_to new_user_session_url
    
    get :inbound_delivery_log
    assert_redirected_to new_user_session_url
    
    post :save_inbound_delivery_log
    assert_redirected_to new_user_session_url
    
    get :outbound_delivery_log
    assert_redirected_to new_user_session_url
    
    post :save_outbound_delivery_log
    assert_redirected_to new_user_session_url
    
    get :buyer_invoices
    assert_redirected_to new_user_session_url
  end
  
end
