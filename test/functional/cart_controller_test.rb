require 'test_helper'

class CartControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  test "should get index" do
    get :index
    
    assert_response :success
    assert_not_nil assigns(:cart)
    assert_not_nil session[:cart_id]
  end
  
end
