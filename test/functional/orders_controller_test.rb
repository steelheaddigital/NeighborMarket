require 'test_helper'

class OrdersControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  def setup
    @user  = users(:buyer_user)
    sign_in @user
  end
  
  test "should get new" do    
    post :new, :cart => {}
    
    assert :success
    assert_not_nil assigns(:order)
  end
  
  test "should create order" do 
    assert_difference 'Order.count' do
      post :create
    end
    
    assert_not_nil assigns(:order)
    assert_not_nil assigns(:order_pickup_date)
    assert_not_nil assigns(:site_settings)
    assert :success
  end
  
  test "anonymous user cannot access protected actions" do
    sign_out @user
        
    post :create
    assert_redirected_to new_user_session_url
  end
end
