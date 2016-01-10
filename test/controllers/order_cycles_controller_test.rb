require 'test_helper'

class OrderCyclesControllerTest < ActionController::TestCase
  include Devise::TestHelpers

  def setup
    @user  = users(:manager_user)
    sign_in @user
  end

  test 'should get index' do
    get :index

    assert_response :success
    assert_not_nil assigns(:order_cycle)
  end

  test 'should update order_cycle_settings and create new order cycle if commit equals Start New Cycle' do
    current_order_cycle_id = order_cycles(:current).id
    
    assert_difference 'OrderCycle.count' do
      post :update, id: current_order_cycle_id, :order_cycle_setting => {:recurring => "true", :interval => "day"}, :order_cycle => {:start_date => Date.current, :end_date => Date.current + 1.day, :seller_delivery_date => Date.current + 1.day, :buyer_pickup_date => Date.current + 1.day}, :commit => 'Save and Start New Cycle'
    end
    
    assert_redirected_to order_cycles_path
    assert_not_nil assigns(:order_cycle)
  end

  test "should update order_cycle_settings if commit does not equal 'Start New Cycle'" do
    current_order_cycle_id = order_cycles(:current).id
    
    assert_no_difference 'OrderCycle.count' do
      post :update, id: current_order_cycle_id, :order_cycle_setting => { id: 1, :recurring => "false", :interval => "day"}, :order_cycle => {:start_date => Date.current - 1.day, :end_date => Date.current + 1.day, :seller_delivery_date => Date.current + 1.day, :buyer_pickup_date => Date.current + 1.day}, :commit => 'Update Settings'
    end
    
    assert OrderCycle.find(current_order_cycle_id).status == "current", "Order cycle status was #{OrderCycle.find(current_order_cycle_id).status} but should have been current"
    assert_redirected_to order_cycles_path
    assert_not_nil assigns(:order_cycle)
  end

  test 'anonymous user cannot access protected actions' do
    sign_out @user
    order_cycle = OrderCycle.first

    get :index
    assert_redirected_to new_user_session_path

    
    post :update, id: order_cycle.id
    assert_redirected_to new_user_session_path
  end
  
  test 'signed in user that is not manager cannot access protected actions' do
    sign_out @user
    @user = users(:approved_seller_user)
    sign_in @user
    order_cycle = OrderCycle.first

    get :index
    assert_response :not_found
    
    post :update, id: order_cycle.id
    assert_response :not_found
  end
end
