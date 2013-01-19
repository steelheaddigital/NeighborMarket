require 'test_helper'

class CartControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  test "should get index" do
    get :index
    
    assert_response :success
    assert_not_nil assigns(:cart)
    assert_not_nil session[:cart_id]
  end
  
  test "should get item_count" do
    get :item_count, :format => :json
    
    assert_response :success
    assert_not_nil assigns(:item_count)
  end
  
end
