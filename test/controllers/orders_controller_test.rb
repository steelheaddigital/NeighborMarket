require 'test_helper'

class OrdersControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  def setup
    @user  = users(:buyer_user)
    sign_in @user
  end
  
  test "should get new and update current order when buyer has an open order" do    
    post :new, :cart => {}
    
    assert :success
    assert_not_nil assigns(:order)
  end
  
  test "should get new when buyer has no open order" do
    sign_out @user
    @user  = users(:buyer_user_no_order)
    sign_in @user
    
    post :new, :cart => { }
    
    assert :success
    assert_not_nil assigns(:order)
  end
  
  test "create should update current order when buyer has an open order" do
    cart = carts(:full)
    cart_items(:one).update_attribute(:quantity, 1)
    cart_items(:four).update_attribute(:quantity, 1)
    mock_payment_processor = Minitest::Mock.new
    mock_payment_processor.expect :purchase, 'http://processor-path', [Order, Object]

    Order.stub_any_instance :payment_processor, mock_payment_processor do
      assert_no_difference 'Order.count' do
        post :create, { :order => { :deliver => false } }, {cart_id: cart.id}
      end
      
      assert_not_nil assigns(:order), "order was nil"
      assert_redirected_to 'http://processor-path'
    end
  end
  
  test "create should create new order when buyer has no open order" do 
    sign_out @user
    @user  = users(:buyer_user_no_order)
    sign_in @user
    cart = carts(:full)
    cart_items(:one).update_attribute(:quantity, 1)
    cart_items(:four).update_attribute(:quantity, 1)
    mock_payment_processor = Minitest::Mock.new
    mock_payment_processor.expect :purchase, 'http://processor-path', [Order, Object]

    Order.stub_any_instance :payment_processor, mock_payment_processor do
      assert_difference 'Order.count' do
        post :create, { :order => { :deliver => false } }, {cart_id: cart.id}
      end
    
      assert_not_nil assigns(:order)
      assert_redirected_to 'http://processor-path'
    end
  end
  
  test "finish should get finish" do
    order = orders(:current)
    cart = carts(:full)
    get(:finish, { id: order.id }, { cart_id: cart.id })
    
    assert_response :success
    assert_not_nil assigns(:order)
    assert_not_nil assigns(:order_pickup_date)
    assert_not_nil assigns(:site_settings)
  end
  
  test "should get edit" do
    order = orders(:current)
    get :edit, :id => order.id
    
    assert_response :success
    assert_not_nil assigns(:order)
  end
  
  test "should update order" do
    order = orders(:current)
    
    post :update, :id => order.id
    
    assert_not_nil :order
    assert_redirected_to edit_order_path
    assert_equal 'Order successfully updated!', flash[:notice]
  end
  
  test "should update cart_items in order if user is buyer and quantity is increased" do
    sign_out @user
    @user  = users(:buyer_user_not_current)
    sign_in @user
    order = orders(:current_two)
    cart_item = cart_items(:minimum_not_reached_at_order_cycle_end)
    
    post :update, :id => order.id, :order => { :cart_items_attributes => { 0 => { :quantity => 11, :id => cart_item.id } } }
    
    assert_not_nil :order
    assert_redirected_to edit_order_path
    assert_equal 'Order successfully updated!', flash[:notice]
  end
  
  test "should not update cart_items in order if user is buyer and quantity is decreased" do
    sign_out @user
    @user  = users(:buyer_user_not_current)
    sign_in @user
    order = orders(:current_two)
    cart_item = cart_items(:minimum_not_reached_at_order_cycle_end)
    
    post :update, :id => order.id, :order => { :cart_items_attributes => { 0 => { :quantity => 9, :id => cart_item.id } } }
    
    assert_not_nil :order
    assert !assigns(:order).valid?
    assert_equal "Cart items quantity cannot be decreased after your order has been completed. If you need to change this item, please <a href=\"/order_change_request/406222160/new\">send a request</a> to the site manager.", assigns(:order).errors.full_messages.first
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
    
    assert_difference 'Order.count', -1 do
      post :destroy, :id => order.id
    end
    
    assert_not_nil assigns(:order)
    assert_redirected_to root_path
    assert_equal 'Order successfully cancelled', flash[:notice]
    
  end
  
  test "user cannot access order other than their own" do
    order = orders(:not_current)
    
    get :edit, :id => order.id 
    assert_response :not_found
    
    post :update, :id => order.id 
    assert_response :not_found
    
    get :show, :id => order.id
    assert_response :not_found
    
    post :destroy, :id => order.id
    assert_response :not_found
  end
  
  test "anonymous user cannot access protected actions" do
    sign_out @user
    
    order = orders(:current)
        
    post :create
    assert_redirected_to new_user_session_path
    
    get :edit, :id => order.id 
    assert_redirected_to new_user_session_path
    
    post :update, :id => order.id 
    assert_redirected_to new_user_session_path
    
    get :show, :id => order.id
    assert_redirected_to new_user_session_path
    
    post :destroy, :id => order.id
    assert_redirected_to new_user_session_path
  end
end
