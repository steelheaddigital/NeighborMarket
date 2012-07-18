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
    
  end
  
  test "should get current_inventory" do
    get :current_inventory
    
    assert_response :success
    assert_not_nil assigns(:current_inventory)
    
  end
  
  test "should get orders" do
    get :orders
    
    assert_response :success
    assert_not_nil assigns(:cart_items)
    
  end
  
  test "anonymous user cannot access protected actions" do
    sign_out @user
    
    assert_raise CanCan::AccessDenied do
      get :index
    end
    
    assert_raise CanCan::AccessDenied do
      get :current_inventory
    end
    
    assert_raise CanCan::AccessDenied do
      get :orders
    end
  end
  
end
