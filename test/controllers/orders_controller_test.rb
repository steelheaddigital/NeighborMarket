require 'test_helper'

class OrdersControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  def setup
    @user  = users(:buyer_user)
    sign_in @user
  end
  
  test "should get new and update current order when buyer has an open order" do 
    cart = carts(:full)

    post :new, { cart: {}, paying_online: true }, cart_id: cart.id
    
    assert :success
    assert_not_nil assigns(:order)
    assert_equal assigns(:order).paying_online, true
  end
  
  test "should get new when buyer has no open order" do
    cart = carts(:no_order)
    
    post :new, { cart: {} }, cart_id: cart.id
    
    assert :success
    assert_not_nil assigns(:order)
  end
  
  test "create should update current order when buyer has an open order" do
    cart = carts(:full)
    mock_payment_processor = Minitest::Mock.new
    mock_payment_processor.expect :purchase, nil, [Order, Cart, Object]

    Order.stub_any_instance :payment_processor, mock_payment_processor do
      assert_no_difference 'Order.count' do
        post :create, { :order => { :deliver => false } }, { cart_id: cart.id }
      end
      
      mock_payment_processor.verify
      assert_not_nil assigns(:order), "order was nil"
      assert_redirected_to 'http://test.host/orders/finish'
    end
  end
  
  test "create should create new order when buyer has no open order" do 
    cart = carts(:no_order)

    assert_difference 'Order.count' do
      post :create, { :order => { :deliver => false }, paying_online: true }, {cart_id: cart.id}
    end
  
    assert_not_nil assigns(:order)
    assert_redirected_to finish_order_path
  end
  
  test "finish should get finish" do
    order = orders(:current)
    cart = Cart.create({})
    get(:finish, { id: order.id }, { cart_id: cart.id })
    
    assert_response :success
    assert_not_nil assigns(:order)
    assert_not_nil assigns(:order_pickup_date)
    assert_not_nil assigns(:site_settings)
  end
  
  test "should show order" do
    order = orders(:current)
    
    get :show, :id => order.id
    
    assert_not_nil :order
    assert_not_nil :site_settings
  end
  
  test "should destroy order" do
    sign_out @user
    @user  = users(:manager_user)
    sign_in @user
    
    order = orders(:current)
    
    mock_payment_processor = Minitest::Mock.new
    mock_payment_processor.expect :refund, nil, [payments(:one), 100.00]

    Payment.stub_any_instance :payment_processor, mock_payment_processor do
      post :destroy, id: order.id

      assert_equal true, Order.find(order.id).canceled
      assert_not_nil assigns(:order)
      assert_redirected_to site_settings_path
      assert_equal 'Order successfully cancelled', flash[:notice]
    end
  end
  
  test "should get edit" do
    order = orders(:current)
    
    get :edit, :id => order.id
    
    assert_response :success
    assert_not_nil :order
  end

  test 'update redirects to checkout url if order was paid online and cart items with online payment were changed' do
    order = orders(:current)
    mock_payment_processor = Minitest::Mock.new
    mock_payment_processor.expect :checkout, 'http://processor-checkout-url', [Cart, String, String]
    
    @controller.stub :payment_processor, mock_payment_processor do
      post :update, id: order.id
    end

    mock_payment_processor.verify
    assert_redirected_to 'http://processor-checkout-url'
  end

  test 'update completes update and redirects to show order if order was paid online but no online payment items were changed' do
    order = orders(:current)
    mock_payment_processor = Minitest::Mock.new
    mock_payment_processor.expect :checkout, false, [Cart, String, String]
    
    @controller.stub :payment_processor, mock_payment_processor do
      post :update, id: order.id
    end

    mock_payment_processor.verify
    assert_redirected_to order_path(order)
    assert_equal 'Order successfully updated', flash[:notice]
  end

  test 'update completes update and redirects to show order if order was not paid online' do
    sign_out @user
    @user = users(:buyer_user_not_current)
    sign_in @user
    order = orders(:current_two)

    post :update, id: order.id

    assert_redirected_to order_path(order)
    assert_equal 'Order successfully updated', flash[:notice]
  end

  test 'update renders edit if update fails' do
    order = orders(:current)
    
    Order.stub_any_instance :update_and_purchase, false do
      post :update, id: order.id
    end

    assert_response :success
    assert_template :edit
  end

  test 'complete_update redirects to show on success' do
    order = orders(:current)
    cart = carts(:minimum)

    Order.stub_any_instance :purchase, true do
      get :complete_update, order_id: order.id, cart_id: cart.id
    end

    assert_redirected_to order_path(order)
    assert_equal 'Order successfully updated', flash[:notice]
  end

  test 'complete_update redirects to edit on failure' do
    order = orders(:current)
    cart = carts(:minimum)

    Order.stub_any_instance :purchase, false do
      get :complete_update, order_id: order.id, cart_id: cart.id
    end

    assert_redirected_to edit_order_path(order)
  end

  test "user cannot access order other than their own" do
    order = orders(:not_current)
    
    get :show, :id => order.id
    assert_response :not_found
    
    get :edit, :id => order.id
    assert_response :not_found

    post :destroy, :id => order.id
    assert_response :not_found

    post :update, :id => order.id
    assert_response :not_found

    post :complete_update, :id => order.id
    assert_response :not_found
  end
  
  test "anonymous user cannot access protected actions" do
    sign_out @user
    
    order = orders(:current)
        
    post :create
    assert_redirected_to new_user_session_path
    
    get :show, :id => order.id
    assert_redirected_to new_user_session_path

    get :edit, :id => order.id
    assert_redirected_to new_user_session_path
    
    post :destroy, :id => order.id
    assert_redirected_to new_user_session_path

    post :update, :id => order.id
    assert_redirected_to new_user_session_path

    post :complete_update, :id => order.id
    assert_redirected_to new_user_session_path
  end
end
