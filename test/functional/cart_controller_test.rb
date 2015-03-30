require 'test_helper'

class CartControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  test "should get index" do
    get :index
    
    assert_response :success
    assert_not_nil assigns(:cart)
  end
  
  test "should get item_count" do
    get :item_count, :format => :json
    
    assert_response :success
    assert_not_nil assigns(:item_count)
  end
  
end
