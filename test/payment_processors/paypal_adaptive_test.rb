require 'test_helper'

class PaypalAdaptiveTest < ActiveSupport::TestCase
  include PaymentProcessor

  test 'purchase_should_create_payments' do
    order = orders(:current)
    receiver_list = {
      receiver: [{
        amount: 280.00,
        invoiceId: 3,
        email: 'approvedseller@test.com'
      }]
    }
    payment_params = {
      actionType: 'PAY',
      currencyCode: 'USD',
      returnUrl: "http://testhost/orders/#{order.id}/finish",
      cancelUrl: 'http://testhost/cart',
      ipnNotificationUrl: 'http://testhost/payments/confirm',
      reverseAllParallelPaymentsOnError: true,
      receiverList: receiver_list
    }
    paypal_response = Minitest::Mock.new
    paypal_response.expect :success?, true
    paypal_response.expect :payment_exec_status, 'SUCCESS'
    gateway = Minitest::Mock.new
    gateway.expect :build_pay, 'paypal_payment', [payment_params]
    gateway.expect :pay, paypal_response, ['paypal_payment']
    gateway.expect :payment_url, 'http://payment_url', [paypal_response]
    processor = PaypalAdaptive.new(gateway, 'http://testhost')

    result = processor.purchase(order)

    assert_equal 'http://payment_url', result
    gateway.verify
    paypal_response.verify
  end

  test 'confirm_should confirm payments' do
    payment_one = payments(:one)
    payment_two = payments(:two)
    gateway = Minitest::Mock.new
    gateway.expect :ipn_valid?, true, ['raw_post']
    request = Minitest::Mock.new
    request.expect :raw_post, 'raw_post'
    request.expect :params, {
      'transaction': {
        '0': {
          'invoiceId': payment_one.id,
          'id_for_sender': 1,
          'status_for_sender_txn': 'COMPLETE',
          'receiver': payment_one.receiver.email,
          'amount': 10.00
        },
        '1': {
          'invoiceId': payment_two.id,
          'id_for_sender': 2,
          'status_for_sender_txn': 'COMPLETE',
          'receiver': payment_two.receiver.email,
          'amount': 20.00
        }
      }
    }.with_indifferent_access
    processor = PaypalAdaptive.new(gateway, 'testhost')
    
    processor.confirm(request)

    assert_equal '1', payment_one.reload.transaction_id
    assert_equal '2', payment_two.reload.transaction_id
    assert_equal 'COMPLETE', payment_one.reload.status
    assert_equal 'COMPLETE', payment_two.reload.status
    request.verify
    gateway.verify
  end

  test 'confirm_should not update payment if email address does not match' do
    payment_one = payments(:one)
    gateway = Minitest::Mock.new
    gateway.expect :ipn_valid?, true, ['raw_post']
    request = Minitest::Mock.new
    request.expect :raw_post, 'raw_post'
    request.expect :params, {
      'transaction': {
        '0': {
          'invoiceId': payment_one.id,
          'id_for_sender': 1,
          'status_for_sender_txn': 'COMPLETE',
          'receiver': 'bademail@bad.com',
          'amount': 10.00
        }
      }
    }.with_indifferent_access
    processor = PaypalAdaptive.new(gateway, 'testhost')
    
    processor.confirm(request)

    assert payment_one.reload.transaction_id.nil?
    assert payment_one.reload.status.nil?
    request.verify
    gateway.verify
  end

  test 'confirm_should not update payment if amount does not match' do
    payment_one = payments(:one)
    gateway = Minitest::Mock.new
    gateway.expect :ipn_valid?, true, ['raw_post']
    request = Minitest::Mock.new
    request.expect :raw_post, 'raw_post'
    request.expect :params, {
      'transaction': {
        '0': {
          'invoiceId': payment_one.id,
          'id_for_sender': 1,
          'status_for_sender_txn': 'COMPLETE',
          'receiver': payment_one.receiver.email,
          'amount': 15.00
        }
      }
    }.with_indifferent_access
    processor = PaypalAdaptive.new(gateway, 'testhost')
    
    processor.confirm(request)

    assert payment_one.reload.transaction_id.nil?
    assert payment_one.reload.status.nil?
    request.verify
    gateway.verify
  end

  test 'confirm_should not update payment if validation fails' do
    payment_one = payments(:one)
    gateway = Minitest::Mock.new
    gateway.expect :ipn_valid?, false, ['raw_post']
    request = Minitest::Mock.new
    request.expect :raw_post, 'raw_post'
    processor = PaypalAdaptive.new(gateway, 'testhost')
    
    processor.confirm(request)

    assert payment_one.reload.transaction_id.nil?
    assert payment_one.reload.status.nil?
    request.verify
    gateway.verify
  end
end
