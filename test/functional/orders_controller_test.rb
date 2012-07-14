require 'test_helper'

class OrdersControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  def setup
    @user  = users(:buyer_user)
    sign_in @user
  end
  
  test "should get new" do
    cart = Cart.create
    session["cart_id"] = cart.id
    CartItem.create(cart: cart, inventory_item: inventory_items(:one))
    
    get :new
    
    assert :sucess
    assert_not_nil assigns(:order)
  end
  
  test "should create order" do 
    assert_difference 'Order.count' do
      post :create
    end
    
    assert_not_nil assigns(:order)
    assert_redirected_to home_index_url
    assert_equal 'Your order has been submitted. Thank You!', flash[:notice]
  end
  
  test "anonymous user cannot access protected actions" do
    sign_out @user
        
    assert_raise CanCan::AccessDenied do
      post :create
    end
  end
end
