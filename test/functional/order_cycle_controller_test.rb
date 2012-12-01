require 'test_helper'

class OrderCycleControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  def setup
    @user  = users(:manager_user)
    sign_in @user
  end
  
  test "should get order_cycle_settings" do
    get :edit
    
    assert_response :success
    assert_not_nil assigns (:order_cycle_settings)
    assert_not_nil assigns (:order_cycle)
  end
  
  test "should update order_cycle_settings and order cycle if commit equals 'Start New Cycle'" do
    post :update, :order_cycle_setting => {:recurring => "true", :interval => "1"}, :order_cycle => {:start_date => Date.current, :end_date => Date.current + 1.day, :seller_delivery_date => Date.current + 1.day, :buyer_pickup_date => Date.current + 1.day}, :commit => 'Start New Cycle'
    
    assert_redirected_to edit_order_cycle_index_path
    assert_not_nil assigns (:order_cycle_settings)
    assert_not_nil assigns (:order_cycle)
  end
  
  test "should update order_cycle_settings but not order cycle if commit does not equal 'Start New Cycle'" do
    post :update, :order_cycle_setting => {:recurring => "true", :interval => "1"}, :order_cycle => {:start_date => Date.current, :end_date => Date.current + 1.day, :seller_delivery_date => Date.current + 1.day, :buyer_pickup_date => Date.current + 1.day}, :commit => 'Save Settings'
    
    assert_redirected_to edit_order_cycle_index_path
    assert_not_nil assigns (:order_cycle_settings)
  end
  
  test "anonymous user cannot access protected actions" do
    sign_out @user
    
    get :edit
    assert_redirected_to new_user_session_url
    
    post :update
    assert_redirected_to new_user_session_url
    
  end
  
end