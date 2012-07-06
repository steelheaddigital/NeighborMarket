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
end
