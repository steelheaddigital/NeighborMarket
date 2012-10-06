require 'test_helper'

class OrdersControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  def setup
    @user  = users(:buyer_user)
    sign_in @user
  end
  
  test "should get new and update current order when buyer has an open order" do    
    post :new, :cart => {}
    
    assert :success
    assert_not_nil assigns(:order)
  end
  
  test "should get new when buyer has no open order" do
    sign_out @user
    @user  = users(:buyer_user_no_order)
    sign_in @user
    
    post :new, :cart => { }
    
    assert :success
    assert_not_nil assigns(:order)
  end
  
  test "create should update current order when buyer has an open order" do 
    assert_no_difference 'Order.count' do
      post :create
    end
    
    assert_not_nil assigns(:order)
    assert_not_nil assigns(:order_pickup_date)
    assert_not_nil assigns(:site_settings)
    assert :success
  end
  
  test "create should create new order when buyer has no open order" do 
    sign_out @user
    @user  = users(:buyer_user_no_order)
    sign_in @user
    
    assert_difference 'Order.count' do
      post :create
    end
    
    assert_not_nil assigns(:order)
    assert_not_nil assigns(:order_pickup_date)
    assert_not_nil assigns(:site_settings)
    assert :success
  end
  
  test "should get edit" do
    order = orders(:current)
    get :edit, :id => order.id
    
    assert_response :success
    assert_not_nil assigns(:order)
  end
  
  test "should update order" do
    
    order = orders(:current)
    
    post :update, :id => order.id
    
    assert_not_nil :order
    assert_redirected_to edit_order_path
    assert_equal 'Order successfully updated!', flash[:notice]
    
  end
  
  test "should show order" do
    
    order = orders(:current)
    
    get :show, :id => order.id
    
    assert_not_nil :order
    
  end
  
  test "anonymous user cannot access protected actions" do
    sign_out @user
    
    order = orders(:current)
        
    post :create
    assert_redirected_to new_user_session_url
    
    get :edit, :id => order.id 
    assert_redirected_to new_user_session_url
    
    post :update, :id => order.id 
    assert_redirected_to new_user_session_url
    
    get :show, :id => order.id
    assert_redirected_to new_user_session_url
    
  end
end
