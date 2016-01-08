require 'test_helper'

class PaymentsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  def setup
    @user = users(:manager_user)
    sign_in @user
  end

  test 'destroy should redirect to back on success' do
    request.env['HTTP_REFERER'] = 'back'
    payment = payments(:one)
    payment_processor = Minitest::Mock.new
    payment_processor.expect :refund, Payment.new, [payment, 100.00]

    Payment.stub_any_instance :payment_processor, payment_processor do
      post :destroy, id: payment.id
    end

    assert_redirected_to 'back'
    assert_equal 'Payment successfully refunded', flash[:notice]
  end

  test 'destroy should redirect to back on error and show error message' do
    request.env['HTTP_REFERER'] = 'back'
    payment = payments(:one)
    payment_processor = Minitest::Mock.new
    payment_processor.expect :refund, Payment.new do 
      fail PaymentProcessor::PaymentError, 'Oh No! Refund Fails!'
    end

    Payment.stub_any_instance :payment_processor, payment_processor do
      post :destroy, id: payment.id
    end

    assert_redirected_to 'back'
    assert_equal 'Payment could not be refunded because Oh No! Refund Fails!', flash[:notice]
  end

  test 'anonymous user cannot access protected actions' do
    sign_out @user
    payment = payments(:one)
    
    post :destroy, id: payment.id
    assert_redirected_to new_user_session_path
  end

  test 'signed in user that is not manager cannot access protected actions' do
    sign_out @user
    @user = users(:approved_seller_user)
    sign_in @user
    payment = payments(:one)
    
    post :destroy, id: payment.id
    assert_response :not_found
  end
end
