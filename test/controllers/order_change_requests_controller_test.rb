require 'test_helper'

class OrderChangeRequestsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  def setup
    @user  = users(:buyer_user)
    sign_in @user
  end
  
  test "should get index" do
    sign_out @user
    @user  = users(:manager_user)
    sign_in @user

    get :index
    
    assert_response :success
    assert_not_nil assigns(:requests)
  end

  test "should get change_request" do
    order = orders(:current)
    get :new, :order_id => order.id
    
    assert_response :success
    assert_not_nil assigns(:order)
    assert_not_nil assigns(:request)
  end
  
  test "should send_change_request" do
    order = orders(:current)
    post :create, {:order_id => order.id, :order_change_request => {:description => "Test Description"} }
    
    assert_not_nil assigns(:order)
    assert_not_nil assigns(:request)
    assert_equal "Test Description", assigns(:request).description
    assert_equal order, assigns(:request).order
    assert_redirected_to order_path(:id => order.id)
  end
  
  test "should complete change request" do
    sign_out @user
    @user  = users(:manager_user)
    sign_in @user
    request = order_change_requests(:one)
    
    post :complete, :id => request.id
    
    request.reload
    assert_redirected_to order_change_requests_path
    assert_equal 'Request successfully completed.', flash[:notice]
    assert request.complete
  end
  
  test "anonymous user cannot access protected actions" do
    sign_out @user
    order = orders(:current)
    request = order_change_requests(:one)
    
    get :index
    assert_redirected_to new_user_session_path

    get :new, :order_id => order.id
    assert_redirected_to new_user_session_path
    
    post :create, :order_id => order.id
    assert_redirected_to new_user_session_path
    
    post :complete, :id => request.id
    assert_redirected_to new_user_session_path
    
  end

  test "signed in user that is not manager cannot access protected actions" do
    sign_out @user
    @user  = users(:approved_seller_user)
    sign_in @user
    request = order_change_requests(:one)

    post :complete, :id => request.id
    assert_response :not_found
    
    get :index
    assert_response :not_found
  end
end