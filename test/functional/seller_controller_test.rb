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
    assert_equal 6, assigns(:current_inventory).count
    assert_not_nil assigns(:all_inventory)
    assert_equal 2, assigns(:all_inventory).count       
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
  
  test "should get sales_report" do
    get :sales_report
    
    assert_response :success
  end
  
  test "should get sales_report_details" do
    post :sales_report_details, :start_date => {:year => "2012", :month => "08", :day => "16"}, :end_date => {:year => "2012", :month => "08", :day => "17"}
    
    assert_response :success
    assert_not_nil assigns(:items)
    assert_not_nil assigns(:begin_date)
    assert_not_nil assigns(:end_date)
    assert_not_nil assigns(:total_price)
    assert_not_nil assigns(:total_quantity)
  end
  
  test "should get sales_report_details js" do
    post :sales_report_details, :format => 'js', :start_date => {:year => "2012", :month => "08", :day => "16"}, :end_date => {:year => "2012", :month => "08", :day => "17"}
    
    assert_response :success
    assert_not_nil assigns(:items)
    assert_not_nil assigns(:begin_date)
    assert_not_nil assigns(:end_date)
    assert_not_nil assigns(:total_price)
    assert_not_nil assigns(:total_quantity)
    assert_equal response.content_type, Mime::JS
  end
  
  test "should get sales_report_details when values are blank" do
    post :sales_report_details, :start_date => {:year => "", :month => "", :day => ""}, :end_date => {:year => "", :month => "", :day => ""}
    
    assert_response :success
    assert_not_nil assigns(:items)
    assert_not_nil assigns(:begin_date)
    assert_not_nil assigns(:end_date)
    assert_not_nil assigns(:total_price)
    assert_not_nil assigns(:total_quantity)
  end
  
  test "should export csv if commit equals Export to CSV" do
    post :sales_report_details, :commit => "Export to CSV", :start_date => {:year => "2012", :month => "08", :day => "16"}, :end_date => {:year => "2012", :month => "08", :day => "17"}
    
    assert_equal("Item Name,Price Per Unit,Total Units Sold,Total Price\nCarrot,10.0,20,200.0\ntest,10.0,3,30.0\ntest,10.0,5,50.0\nJam,10.0,10,100.0\n", @response.body.to_s)
    assert_response(:success)
  end
  
  test "anonymous user cannot access protected actions" do
    sign_out @user
    
    get :index
    assert_redirected_to new_user_session_path
    
    get :pick_list
    assert_redirected_to new_user_session_path
    
    get :packing_list
    assert_redirected_to new_user_session_path
    
  end
  
end
