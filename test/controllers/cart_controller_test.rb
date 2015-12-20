require 'test_helper'

class CartControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  def setup
    @user  = users(:buyer_user)
    sign_in @user
  end

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
  
  test 'checkout renders not_buyer if user is not signed in' do
    sign_out @user
    cart = carts(:full)
    session[:cart_id] = cart.id
    post :checkout

    assert_response :success
    assert_template :not_buyer
  end

  test 'Continue Shopping button redirects to last search path' do
    session[:last_search_path] = '/last/search/path'
    
    post :checkout, commit: 'Continue Shopping'

    assert_redirected_to '/last/search/path'
  end

  test 'Continue Shopping button redirects to home page if last_search_path is null' do    
    post :checkout, commit: 'Continue Shopping'

    assert_redirected_to root_path
  end

  test 'Checkout and pay online calls payment processor checkout and redirects to correct path' do
    cart = carts(:full)
    session[:cart_id]  = cart.id
    mock_payment_processor = Minitest::Mock.new
    mock_payment_processor.expect :checkout, 'http://processor-path', [cart, 'http://test.host/orders/new?paying_online=true',  'http://test.host/cart']
    
    @controller.stub :payment_processor, mock_payment_processor do
      post :checkout, commit: 'Checkout and pay online'
    end

    mock_payment_processor.verify
    assert_redirected_to 'http://processor-path'
  end

  test 'If commit is not pay online or continue shopping redirects to new_order_path' do
    post :checkout, commit: 'Confirm order and purchase'

    assert_redirected_to new_order_path
  end
end
