require 'test_helper'

class SessionsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  def setup
    @request.env["devise.mapping"] = Devise.mappings[:user]
  end
  
  test "destroy should destroy cart in session" do
    user  = users(:buyer_user)
    sign_in user

    cart = Cart.create({})
    session[:cart_id] = cart.id
    assert_difference 'Cart.count', -1 do
      post :destroy
    end
    
  end
  
end
