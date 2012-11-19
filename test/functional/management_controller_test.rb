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
    
    assert_redirected_to inbound_delivery_log_management_index_path
    assert_equal(true, cart_item.reload.delivered) 
  end
  
  test "should get outbound_delivery_log" do
    get :outbound_delivery_log
    
    assert_response :success
    assert_not_nil assigns (:orders)
  end
  
  test "should update outbound delivery log" do
    order = orders(:current)
    post :save_outbound_delivery_log, :orders => {"0" => {:id => order.id, :complete => "true"}}
    
    assert_redirected_to outbound_delivery_log_management_index_path
    assert_equal(true, order.reload.complete) 
  end
  
  test "should get buyer_invoices" do
    get :buyer_invoices
    
    assert_response :success
    assert_not_nil assigns (:orders)
  end
  
  test "should get order_cycle_settings" do
    get :order_cycle
    
    assert_response :success
    assert_not_nil assigns (:order_cycle_settings)
    assert_not_nil assigns (:order_cycle)
  end
  
  test "should update order_cycle_settings and order cycle if commit equals 'Start New Cycle'" do
    post :update_order_cycle, :order_cycle_setting => {:recurring => "true", :interval => "1"}, :order_cycle => {:start_date => Date.current, :end_date => Date.current + 1.day, :seller_delivery_date => Date.current + 1.day, :buyer_pickup_date => Date.current + 1.day}, :commit => 'Start New Cycle'
    
    assert_redirected_to order_cycle_management_index_path
    assert_not_nil assigns (:order_cycle_settings)
    assert_not_nil assigns (:order_cycle)
  end
  
  test "should update order_cycle_settings but not order cycle if commit does not equal 'Start New Cycle'" do
    post :update_order_cycle, :order_cycle_setting => {:recurring => "true", :interval => "1"}, :order_cycle => {:start_date => Date.current, :end_date => Date.current + 1.day, :seller_delivery_date => Date.current + 1.day, :buyer_pickup_date => Date.current + 1.day}, :commit => 'Save Settings'
    
    assert_redirected_to order_cycle_management_index_path
    assert_not_nil assigns (:order_cycle_settings)
  end
  
  test "should get site_settings" do
    get :site_setting
    
    assert_response :success
    assert_not_nil assigns (:site_settings)
  end
  
  test "should update site_settings" do
    post :update_site_setting, :site_setting => {:domain => "http://mysite.com", :site_name => "Test", :drop_point_address => "123 Test St.", :drop_point_city => "Portland", :drop_point_state => "Oregon", :drop_point_zip => "97218"}
    
    assert_redirected_to site_setting_management_index_path
    assert_not_nil assigns (:site_settings)
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
    
    get :order_cycle
    assert_redirected_to new_user_session_url
    
    get :site_setting
    assert_redirected_to new_user_session_url
    
    post :update_site_setting
    assert_redirected_to new_user_session_url
  end
  
end
