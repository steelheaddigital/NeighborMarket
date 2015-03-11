require 'test_helper'

class ManagementControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  def setup
    @user  = users(:manager_user)
    sign_in @user
  end
  
  test "should get order_cycle_settings" do
    get :edit_order_cycle_settings
    
    assert_response :success
    assert_not_nil assigns (:order_cycle_settings)
    assert_not_nil assigns (:order_cycle)
  end
  
  test "should update order_cycle_settings and create new order cycle if commit equals 'Start New Cycle'" do
    
    assert_difference "OrderCycle.count" do
      post :update_order_cycle_settings, :order_cycle_setting => {:recurring => "true", :interval => "day"}, :order_cycle => {:start_date => Date.current, :end_date => Date.current + 1.day, :seller_delivery_date => Date.current + 1.day, :buyer_pickup_date => Date.current + 1.day}, :commit => 'Save and Start New Cycle'
    end
    
    assert_redirected_to edit_order_cycle_settings_management_index_path
    assert_not_nil assigns (:order_cycle_settings)
    assert_not_nil assigns (:order_cycle)
  end
  
  test "should update order_cycle_settings but not order cycle if commit does not equal 'Start New Cycle'" do
    current_order_cycle_id = order_cycles(:current).id
    
    assert_no_difference "OrderCycle.count" do
      post :update_order_cycle_settings, :order_cycle_setting => {:recurring => "true", :interval => "day"}, :order_cycle => {:start_date => Date.current - 1.day, :end_date => Date.current + 1.day, :seller_delivery_date => Date.current + 1.day, :buyer_pickup_date => Date.current + 1.day}, :commit => 'Update Settings'
    end
    
    assert OrderCycle.find(current_order_cycle_id).status == "current", "Order cycle status was #{OrderCycle.find(current_order_cycle_id).status} but should have been current"
    assert_redirected_to edit_order_cycle_settings_management_index_path
    assert_not_nil assigns (:order_cycle_settings)
    assert_not_nil assigns (:order_cycle)
  end
  
  test "should get approve_sellers" do
    get :approve_sellers
    
    assert_response :success
    assert_not_nil assigns(:sellers)
  end
  
  test "should get approve_sellers js" do
    get :approve_sellers, :format => 'js'
    
    assert_response :success
    assert_not_nil assigns (:sellers)
    assert_equal response.content_type, Mime::JS
  end
  
  test "should get user_search" do
    get :user_search
    
    assert_response :success
  end
  
  test "should get user_search js" do
    get :user_search, :format => 'js'
    
    assert_response :success
    assert_equal response.content_type, Mime::JS
  end
  
  test "should get user_search_results" do
    get :user_search_results, :keywords => 'manager'
    
    assert_response :success
    assert_not_nil assigns (:users)
  end
  
  test "should get user_search_results js" do
    get :user_search_results, :keywords => 'manager', :format => 'js'
    
    assert_response :success
    assert_not_nil assigns (:users)
    assert_equal response.content_type, Mime::JS
  end
  
  test "should get categories" do
    get :categories
    
    assert_response :success
    assert_not_nil assigns(:categories)
    assert_equal 3, assigns(:categories).count
  end
  
  test "should get categories js" do
    get :categories, :format => 'js'
    
    assert_response :success
    assert_not_nil assigns (:categories)
    assert_equal response.content_type, Mime::JS
  end
  
  test "should get inbound_delivery_log" do
    get :inbound_delivery_log
    
    assert_response :success
    assert_not_nil assigns(:items)
    assert_not_nil assigns(:previous_order_cycles)
    assert_not_nil assigns(:selected_previous_order_cycle)
  end
  
  test "should get previous inbound_delivery_log" do
    order_cycle = order_cycles(:complete)
    get :inbound_delivery_log, :selected_previous_order_cycle => {:id => order_cycle.id}
    
    assert_response :success
    assert_not_nil assigns(:items)
    assert_not_nil assigns(:previous_order_cycles)
    assert_not_nil assigns(:selected_previous_order_cycle)
  end
  
  test "should get inbound_delivery_log pdf" do
    get :inbound_delivery_log, :commit => 'Printable Delivery Log (PDF)'
    
    assert_response :success
    assert_not_nil assigns (:items)
    assert_equal response.content_type, "application.pdf"
  end
  
  test "should get previous inbound_delivery_log pdf" do
    order_cycle = order_cycles(:complete)
    get :inbound_delivery_log, :selected_previous_order_cycle => {:id => order_cycle.id}, :commit => 'Printable Delivery Log (PDF)'
    
    assert_response :success
    assert_not_nil assigns(:items)
    assert_not_nil assigns(:previous_order_cycles)
    assert_not_nil assigns(:selected_previous_order_cycle)
    assert_equal response.content_type, "application.pdf"
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
    assert_not_nil assigns(:orders)
    assert_not_nil assigns(:previous_order_cycles)
    assert_not_nil assigns(:selected_previous_order_cycle)
  end
  
  test "should get previous outbound_delivery_log" do
    order_cycle = order_cycles(:complete)
    get :outbound_delivery_log, :selected_previous_order_cycle => {:id => order_cycle.id}
    
    assert_response :success
    assert_not_nil assigns(:orders)
    assert_not_nil assigns(:previous_order_cycles)
    assert_not_nil assigns(:selected_previous_order_cycle)
  end
  
  test "should get outbound_delivery_log pdf" do
    get :outbound_delivery_log, :commit => 'Printable Delivery Log (PDF)'
    
    assert_response :success
    assert_not_nil assigns (:orders)
    assert_not_nil assigns(:previous_order_cycles)
    assert_not_nil assigns(:selected_previous_order_cycle)
    assert_equal response.content_type, "application.pdf"
  end
  
  test "should get previous outbound_delivery_log pdf" do
    order_cycle = order_cycles(:complete)
    get :outbound_delivery_log, :selected_previous_order_cycle => {:id => order_cycle.id}, :commit => 'Printable Delivery Log (PDF)'
    
    assert_response :success
    assert_not_nil assigns (:orders)
    assert_not_nil assigns(:previous_order_cycles)
    assert_not_nil assigns(:selected_previous_order_cycle)
    assert_equal response.content_type, "application.pdf"
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
    assert_not_nil assigns(:previous_order_cycles)
    assert_not_nil assigns(:selected_previous_order_cycle)
    assert_not_nil assigns(:site_settings)
  end
  
  test "should get previous buyer_invoices" do
    order_cycle = order_cycles(:complete)
    get :buyer_invoices, :selected_previous_order_cycle => {:id => order_cycle.id}
    
    assert_response :success
    assert_not_nil assigns(:orders)
    assert_not_nil assigns(:previous_order_cycles)
    assert_not_nil assigns(:selected_previous_order_cycle)
    assert_not_nil assigns(:site_settings)
  end
  
  test "should get buyer_invoices pdf" do
    get :buyer_invoices, :commit => 'Printable Invoices (PDF)'
    
    assert_response :success
    assert_not_nil assigns (:orders)
    assert_not_nil assigns(:site_settings)
    assert_equal response.content_type, "application.pdf"
  end
  
  test "should get previous buyer_invoices pdf" do
    order_cycle = order_cycles(:complete)
    get :buyer_invoices, :selected_previous_order_cycle => {:id => order_cycle.id}, :commit => 'Printable Invoices (PDF)'
    
    assert_response :success
    assert_not_nil assigns(:orders)
    assert_not_nil assigns(:previous_order_cycles)
    assert_not_nil assigns(:selected_previous_order_cycle)
    assert_not_nil assigns(:site_settings)
    assert_equal response.content_type, "application.pdf"
  end
  
  test "should get inventory_item_approval" do
    get :inventory_item_approval
    
    assert_response :success
    assert_not_nil assigns (:inventory_items)
  end
  
  test "should update inventory item approval" do
    inventory_item = inventory_items(:two)
    post :update_inventory_item_approval, :inventory_items => {"0" => {:id => inventory_item.id, :approved => "true"}}
    
    assert_redirected_to inventory_item_approval_management_index_path
    assert inventory_item.reload.approved
  end
  
  test "should get inventory" do
    get :inventory
    
    assert_response :success
    assert_not_nil assigns (:inventory_items)
  end
  
  test "should get inventory js" do
    get :inventory, :format => 'js'
    
    assert_response :success
    assert_not_nil assigns (:inventory_items)
    assert_equal response.content_type, Mime::JS
  end
  
  test "should get edit_inventory" do
    inventory_item = inventory_items(:one)
    get :edit_inventory, :id => inventory_item.id
    
    assert_response :success
    assert_not_nil assigns (:item)
    assert_not_nil assigns (:top_level_categories)
    assert_not_nil assigns (:second_level_categories)
  end
  
  test "should get edit_inventory js" do
    inventory_item = inventory_items(:one)
    get :edit_inventory, :id => inventory_item.id, :format => 'js'
    
    assert_response :success
    assert_not_nil assigns (:item)
    assert_not_nil assigns (:top_level_categories)
    assert_not_nil assigns (:second_level_categories)
    assert_equal response.content_type, Mime::JS
  end
  
  test "should get historical_orders" do
    get :historical_orders
    
    assert_response :success
  end
  
  test "should get historical_orders_report" do
    post :historical_orders_report, :start_date => {:year => "2012", :month => "08", :day => "16"}, :end_date => {:year => "2012", :month => "08", :day => "17"}
    
    assert_response :success
    assert_not_nil assigns(:orders)
  end
  
  test "should get historical_orders_report js" do
    post :historical_orders_report, :format => 'js', :start_date => {:year => "2012", :month => "08", :day => "16"}, :end_date => {:year => "2012", :month => "08", :day => "17"}
    
    assert_response :success
    assert_not_nil assigns(:orders)
    assert_equal response.content_type, Mime::JS
  end
  
  test "should get historical_orders_report when values are blank" do
    post :historical_orders_report, :start_date => {:year => "", :month => "", :day => ""}, :end_date => {:year => "", :month => "", :day => ""}
    
    assert_response :success
    assert_not_nil assigns(:orders)
  end
  
  test "should export csv if commit equals Export to CSV" do
    post :historical_orders_report, :commit => "Export to CSV", :start_date => {:year => "2012", :month => "08", :day => "16"}, :end_date => {:year => "2012", :month => "08", :day => "17"}
    
    assert_match("Seller ID,Buyer ID,Order ID,Item Name,Quantity,Price,Delivery Date\n", @response.body.to_s)
    assert_response(:success)
  end
  
  test "should get new users report" do
    get :new_users_report
    
    assert_response :success
    assert_not_nil assigns(:users)
  end
  
  test "should get updated user profile report" do
    get :updated_user_profile_report
    
    assert_response :success
    assert_not_nil assigns(:users)
  end
  
  test "should get deleted users report" do
    get :deleted_users_report
    
    assert_response :success
    assert_not_nil assigns(:users)
  end
  
  test "should get manage_units" do
    get :manage_units
    
    assert_response :success
    assert_not_nil assigns(:price_units)
    assert_not_nil assigns(:new_unit)
    assert_not_nil assigns(:added_units)
  end
  
  test "should create unit" do    
    assert_difference 'PriceUnit.count' do
      post :create_price_unit, :price_unit => { :name => "TestThree" }
    end
    
    assert_not_nil assigns(:price_units)
    assert_not_nil assigns(:new_unit)
    assert_not_nil assigns(:added_units)
    assert_redirected_to manage_units_management_index_path
    assert_equal 'Unit successfully saved!', flash[:notice]
  end
  
  test "should destroy unit" do
    unit = price_units(:one)
    
    assert_difference 'PriceUnit.count', -1 do
      post :destroy_price_unit, :price_unit => unit
    end
    
    assert_redirected_to manage_units_management_index_path
    assert_equal 'Unit successfully deleted!', flash[:notice]
    
  end
  
  test "should get inventory_item_change_requests" do
    get :inventory_item_change_requests
    
    assert_response :success
    assert_not_nil assigns(:requests)
  end
  
  
  test "anonymous user cannot access protected actions" do
    sign_out @user
    
    get :approve_sellers
    assert_redirected_to new_user_session_path
    
    get :user_search
    assert_redirected_to new_user_session_path
    
    get :user_search_results
    assert_redirected_to new_user_session_path
    
    get :categories
    assert_redirected_to new_user_session_path
    
    get :inbound_delivery_log
    assert_redirected_to new_user_session_path
    
    post :save_inbound_delivery_log
    assert_redirected_to new_user_session_path
    
    get :outbound_delivery_log
    assert_redirected_to new_user_session_path
    
    post :save_outbound_delivery_log
    assert_redirected_to new_user_session_path
    
    get :buyer_invoices
    assert_redirected_to new_user_session_path
    
    get :inventory_item_approval
    assert_redirected_to new_user_session_path
    
    post :update_inventory_item_approval
    assert_redirected_to new_user_session_path
    
    get :inventory
    assert_redirected_to new_user_session_path
    
    post :edit_inventory
    assert_redirected_to new_user_session_path
    
    get :historical_orders
    assert_redirected_to new_user_session_path
    
    post :historical_orders_report
    assert_redirected_to new_user_session_path
    
    get :edit_order_cycle_settings
    assert_redirected_to new_user_session_path
    
    post :update_order_cycle_settings
    assert_redirected_to new_user_session_path
    
     get :new_users_report
     assert_redirected_to new_user_session_path
   
     get :updated_user_profile_report
     assert_redirected_to new_user_session_path
   
     get :deleted_users_report
     assert_redirected_to new_user_session_path
     
     get :manage_units
     assert_redirected_to new_user_session_path
     
     post :create_price_unit
     assert_redirected_to new_user_session_path
     
     post :destroy_price_unit
     assert_redirected_to new_user_session_path
     
     get :inventory_item_change_requests
     assert_redirected_to new_user_session_path
  end
  
  test "signed in user that is not manager cannot access protected actions" do
    sign_out @user
    @user  = users(:approved_seller_user)
    sign_in @user
    
    get :approve_sellers
    assert_response :not_found
    
    get :user_search
    assert_response :not_found
    
    get :user_search_results
    assert_response :not_found
    
    get :categories
    assert_response :not_found
    
    get :inbound_delivery_log
    assert_response :not_found
    
    post :save_inbound_delivery_log
    assert_response :not_found
    
    get :outbound_delivery_log
    assert_response :not_found
    
    post :save_outbound_delivery_log
    assert_response :not_found
    
    get :buyer_invoices
    assert_response :not_found
    
    get :inventory_item_approval
    assert_response :not_found
    
    post :update_inventory_item_approval
    assert_response :not_found
    
    get :inventory
    assert_response :not_found
    
    post :edit_inventory
    assert_response :not_found
    
    get :historical_orders
    assert_response :not_found
    
    post :historical_orders_report
    assert_response :not_found
    
    get :edit_order_cycle_settings
    assert_response :not_found
    
    post :update_order_cycle_settings
    assert_response :not_found
    
    get :new_users_report
    assert_response :not_found
   
    get :updated_user_profile_report
    assert_response :not_found
   
    get :deleted_users_report
    assert_response :not_found
    
    get :manage_units
    assert_response :not_found
    
    post :create_price_unit
    assert_response :not_found
    
    post :destroy_price_unit
    assert_response :not_found
    
    get :inventory_item_change_requests
    assert_response :not_found
  end
  
end
