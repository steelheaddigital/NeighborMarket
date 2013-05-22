require 'test_helper'

class HomeControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  test "should get index" do
    get :index
    assert_response :success
  end

  test "should get user_home for manager" do
    @user  = users(:manager_user)
    sign_in @user
    
    get :user_home
    assert_response :success
    assert_not_nil assigns(:manager)
  end
  
  test "should get user_home for seller" do
    @user  = users(:approved_seller_user)
    sign_in @user
    
    get :user_home
    assert_response :success
    assert_not_nil assigns(:seller)
  end

end
