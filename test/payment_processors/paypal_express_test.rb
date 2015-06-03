require 'test_helper'

class PaypalExpressTest < ActiveSupport::TestCase
  include PaymentProcessor

  def setup
    processor_settings = Minitest::Mock.new
    processor_settings.expect :username, 'username'
    processor_settings.expect :password, 'password'
    processor_settings.expect :api_signature, 'api_signature'
    @processor_settings = processor_settings
  end

  test 'purchase should call paypal checkout and add payments to order' do
    order = orders(:current)
    cart = carts(:full)
    payment_requests = [
      Paypal::Payment::Request.new(
        currency_code: :USD,
        amount: 200.00,
        seller_id: 'approvedseller@test.com'
      )
    ]
    amount = Minitest::Mock.new
    amount.expect :total, 200.00
    payment_info_item = Minitest::Mock.new
    payment_info_item.expect :seller_id, 'approvedseller@test.com'
    payment_info_item.expect :amount, amount
    payment_info_item.expect :transaction_id, 'test_transaction_id'
    payment_info_item.expect :payment_status, 'SUCCESS'

    payment_info = [
      payment_info_item
    ]

    paypal_response = Minitest::Mock.new
    paypal_response.expect :payment_info, payment_info
    gateway = Minitest::Mock.new
    gateway.expect :checkout!, paypal_response, ['test_token', 'test_payer_id', payment_requests]
    processor = PaypalExpress.new(host: 'http://testhost', processor_settings: @processor_settings, gateway: gateway)

    result = processor.purchase(order, cart, token: 'test_token', PayerID: 'test_payer_id')

    assert_equal '/orders/finish', result
    gateway.verify
    paypal_response.verify
  end

  test 'checkout should send request to paypal and return paypal URL' do
    cart = carts(:full)
    payment_requests = [
      Paypal::Payment::Request.new(
        currency_code: :USD,
        amount: 200.00,
        seller_id: 'approvedseller@test.com'
      )
    ]

    paypal_options = {
      no_shipping: true,
      allow_note: false,
      pay_on_paypal: true,
      solution_type: 'Sole',
      landing_page: 'Billing'
    }

    paypal_response = Minitest::Mock.new
    paypal_response.expect :redirect_uri, 'http://paypal_url'
    gateway = Minitest::Mock.new
    gateway.expect :setup, paypal_response, [payment_requests, 'http://testhost/orders/new', 'http://testhost/cart', paypal_options]
    processor = PaypalExpress.new(host: 'http://testhost', processor_settings: @processor_settings, gateway: gateway)

    result = processor.checkout(cart)

    assert_equal 'http://paypal_url', result
    gateway.verify
    paypal_response.verify
  end

  test 'refund should send request to paypal and create new refund payments' do
    payment = payments(:three)
    paypal_options = {
      type: :Partial,
      amount: 10.00
    }

    amount = Minitest::Mock.new
    amount.expect :gross, 10.00
    refund = Minitest::Mock.new
    refund.expect :amount, amount
    refund.expect :transaction_id, 2
    paypal_response = Minitest::Mock.new
    paypal_response.expect :ack, 'Success'
    paypal_response.expect :refund, refund
    gateway = Minitest::Mock.new
    gateway.expect :refund!, paypal_response, [payment.transaction_id, paypal_options]
    processor = PaypalExpress.new(host: 'http://testhost', processor_settings: @processor_settings, gateway: gateway)

    assert_difference 'Payment.count' do
      new_payment = processor.refund(payment, 10.00)
      assert_equal 'PaypalExpress', new_payment.processor_type
      assert_equal 'refund', new_payment.payment_type
      assert_equal payment.receiver_id, new_payment.receiver_id
      assert_equal payment.sender_id, new_payment.sender_id
      assert_equal 10.00, new_payment.amount
      assert_equal 2, new_payment.transaction_id
      assert_equal 'COMPLETE', new_payment.status
    end
    gateway.verify
    paypal_response.verify
  end

  test 'refund raises PaymentError if ack is not Success' do
    payment = payments(:three)
    paypal_options = {
      type: :Partial,
      amount: 10.00
    }

    paypal_response = Minitest::Mock.new
    paypal_response.expect :ack, 'Fail'
    gateway = Minitest::Mock.new
    gateway.expect :refund!, paypal_response, [payment.transaction_id, paypal_options]
    processor = PaypalExpress.new(host: 'http://testhost', processor_settings: @processor_settings, gateway: gateway)

    assert_raises PaymentProcessor::PaymentError do
      processor.refund(payment, 10.00)
    end
    gateway.verify
    paypal_response.verify
  end
end
