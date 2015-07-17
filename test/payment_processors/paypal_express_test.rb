require 'test_helper'

class PaypalExpressTest < ActiveSupport::TestCase
  include PaymentProcessor

  def setup
    processor_settings = Minitest::Mock.new
    processor_settings.expect :username, 'username'
    processor_settings.expect :password, 'password'
    processor_settings.expect :api_signature, 'api_signature'
    processor_settings.expect :app_id, 'app_id'
    @processor_settings = processor_settings
  end

  test 'purchase should call paypal checkout and add payments to order' do
    order = orders(:current)
    cart = carts(:full)
    seller = users(:approved_seller_user)
    payment_requests = [
      Paypal::Payment::Request.new(
        currency_code: :USD,
        amount: 200.00,
        seller_id: seller.user_paypal_express_setting.email_address,
        request_id: "CART#{cart.id}-PAYMENT0"
      )
    ]
    amount = Minitest::Mock.new
    amount.expect :total, 200.00
    amount.expect :fee, 1.00
    payment_info_item = Minitest::Mock.new
    payment_info_item.expect :seller_id, 'approved_seller_user@test.com'
    payment_info_item.expect :amount, amount
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
    permissions = Minitest::Mock.new
    accounts = Minitest::Mock.new
    processor = PaypalExpress.new(host: 'http://testhost', processor_settings: @processor_settings, gateway: gateway, accounts: accounts, permissions: permissions)

    result = processor.purchase(order, cart, token: 'test_token', PayerID: 'test_payer_id')

    assert_equal '/orders/finish', result
    gateway.verify
    paypal_response.verify
  end

  test 'checkout should send request to paypal and return paypal URL' do
    cart = carts(:full)
    seller = users(:approved_seller_user)
    payment_requests = [
      Paypal::Payment::Request.new(
        currency_code: :USD,
        amount: 200.00,
        seller_id: seller.user_paypal_express_setting.email_address,
        request_id: "CART#{cart.id}-PAYMENT0"
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
    gateway.expect :setup, paypal_response, [payment_requests, 'http://testhost/orders/new?paying_online=true', 'http://testhost/cart', paypal_options]
    permissions = Minitest::Mock.new
    accounts = Minitest::Mock.new
    processor = PaypalExpress.new(host: 'http://testhost', processor_settings: @processor_settings, gateway: gateway, accounts: accounts, permissions: permissions)

    result = processor.checkout(cart)

    assert_equal 'http://paypal_url', result
    gateway.verify
    paypal_response.verify
  end

  test 'refund should send request to paypal and create new refund payments' do
    payment = payments(:one)
    paypal_options = {
      type: :Partial,
      amount: 10.00
    }

    amount = Minitest::Mock.new
    amount.expect :gross, 10.00
    amount.expect :fee, 1.00
    refund = Minitest::Mock.new
    refund.expect :amount, amount
    refund.expect :amount, amount
    refund.expect :transaction_id, 2
    paypal_response = Minitest::Mock.new
    paypal_response.expect :ack, 'Success'
    paypal_response.expect :refund, refund
    gateway = Minitest::Mock.new
    gateway.expect :refund!, paypal_response, [payment.transaction_id, paypal_options]
    permissions = Minitest::Mock.new
    accounts = Minitest::Mock.new
    processor = PaypalExpress.new(host: 'http://testhost', processor_settings: @processor_settings, gateway: gateway, accounts: accounts, permissions: permissions)

    assert_difference 'Payment.count' do
      new_payment = processor.refund(payment, 10.00, gateway: gateway)
      assert_equal 'PaypalExpress', new_payment.processor_type
      assert_equal 'refund', new_payment.payment_type
      assert_equal payment.receiver_id, new_payment.receiver_id
      assert_equal payment.sender_id, new_payment.sender_id
      assert_equal 10.00, new_payment.amount
      assert_equal 2, new_payment.transaction_id
      assert_equal 'Completed', new_payment.status
    end
    gateway.verify
    paypal_response.verify
  end

  test 'refund raises PaymentError if ack is not Success' do
    payment = payments(:one)
    paypal_options = {
      type: :Partial,
      amount: 10.00
    }

    paypal_response = Minitest::Mock.new
    paypal_response.expect :ack, 'Fail'
    gateway = Minitest::Mock.new
    gateway.expect :refund!, paypal_response, [payment.transaction_id, paypal_options]
    permissions = Minitest::Mock.new
    accounts = Minitest::Mock.new
    processor = PaypalExpress.new(host: 'http://testhost', processor_settings: @processor_settings, gateway: gateway, accounts: accounts, permissions: permissions)

    assert_raises PaymentProcessor::PaymentError do
      processor.refund(payment, 10.00, gateway: gateway)
    end
    gateway.verify
    paypal_response.verify
  end

  test 'verify_account calls paypal and verifies account' do
    gateway = Minitest::Mock.new
    permissions = Minitest::Mock.new
    accounts = Minitest::Mock.new
    verified_status_request = Minitest::Mock.new
    accounts.expect :build_get_verified_status, verified_status_request, [{ emailAddress: 'testemailaddress', firstName: 'testfirstname', lastName: 'testlastname', matchCriteria: 'NAME' }]
    verified_status_response = Minitest::Mock.new
    user_info = Minitest::Mock.new
    user_info.expect :account_id, 123
    user_info.expect :emailAddress, 'testemailaddress'
    user_info.expect :accountType, 'business'
    verified_status_response.expect :accountStatus, 'verified'
    verified_status_response.expect :userInfo, user_info
    verified_status_response.expect :userInfo, user_info
    verified_status_response.expect :userInfo, user_info
    verified_status_response.expect :success?, true
    accounts.expect :get_verified_status, verified_status_response, [verified_status_request]
    processor = PaypalExpress.new(host: 'http://testhost', processor_settings: @processor_settings, gateway: gateway, accounts: accounts, permissions: permissions)

    result = processor.verify_account 'testemailaddress', 'testfirstname', 'testlastname'

    accounts.verify
    assert_equal 'verified', result[:status]
    assert_equal 123, result[:account_id]
    assert_equal 'testemailaddress', result[:email_address]
    assert_equal 'business', result[:account_type]
  end

  test 'verify_account raises PaymentError if success? is false' do
    gateway = Minitest::Mock.new
    permissions = Minitest::Mock.new
    accounts = Minitest::Mock.new
    verified_status_request = Minitest::Mock.new
    accounts.expect :build_get_verified_status, verified_status_request, [{ emailAddress: 'testemailaddress', firstName: 'testfirstname', lastName: 'testlastname', matchCriteria: 'NAME' }]
    verified_status_response = Minitest::Mock.new
    verified_status_response.expect :success?, false
    error = Minitest::Mock.new
    error.expect :message, 'Oh No, Error!'
    verified_status_response.expect :error, [error]
    accounts.expect :get_verified_status, verified_status_response, [verified_status_request]
    processor = PaypalExpress.new(host: 'http://testhost', processor_settings: @processor_settings, gateway: gateway, accounts: accounts, permissions: permissions)

    assert_raises PaymentProcessor::PaymentError do
      processor.verify_account 'testemailaddress', 'testfirstname', 'testlastname'
    end
    accounts.verify
    error.verify
  end

  test 'request_permissions calls paypal and requests correct permissions' do
    gateway = Minitest::Mock.new
    accounts = Minitest::Mock.new
    permissions = Minitest::Mock.new
    permissions_request = Minitest::Mock.new
    permissions.expect :build_request_permissions, permissions_request, [{ scope: ['REFUND'], callback: 'http://testhost/user_paypal_express_settings/grant_permissions' }]
    request_permissions_response = Minitest::Mock.new
    request_permissions_response.expect :success?, true
    permissions.expect :request_permissions, request_permissions_response, [permissions_request]
    permissions.expect :grant_permission_url, 'grantpermissionsurl', [request_permissions_response]
    processor = PaypalExpress.new(host: 'http://testhost', processor_settings: @processor_settings, gateway: gateway, accounts: accounts, permissions: permissions)
  
    result = processor.request_permissions

    permissions.verify
    assert_equal 'grantpermissionsurl', result
  end

  test 'request_permissions raises PaymentError if success? is false' do
    gateway = Minitest::Mock.new
    accounts = Minitest::Mock.new
    permissions = Minitest::Mock.new
    permissions_request = Minitest::Mock.new
    permissions.expect :build_request_permissions, permissions_request, [{ scope: ['REFUND'], callback: 'http://testhost/user_paypal_express_settings/grant_permissions' }]
    request_permissions_response = Minitest::Mock.new
    request_permissions_response.expect :success?, false
    permissions.expect :request_permissions, request_permissions_response, [permissions_request]
    error = Minitest::Mock.new
    error.expect :message, 'Oh No, Error!'
    request_permissions_response.expect :error, [error]
    processor = PaypalExpress.new(host: 'http://testhost', processor_settings: @processor_settings, gateway: gateway, accounts: accounts, permissions: permissions)
  
    assert_raises PaymentProcessor::PaymentError do
      processor.request_permissions
    end
    permissions.verify
    error.verify
  end

  test 'get_access_token calls paypal and gets access token and secret' do
    gateway = Minitest::Mock.new
    accounts = Minitest::Mock.new
    permissions = Minitest::Mock.new
    access_token_request = Minitest::Mock.new
    permissions.expect :build_get_access_token, access_token_request, [{ token: 'token', verifier: 'verifier' }]
    access_token_response = Minitest::Mock.new
    access_token_response.expect :success?, true
    access_token_response.expect :token, 'accesstoken'
    access_token_response.expect :tokenSecret, 'tokenSecret'
    permissions.expect :get_access_token, access_token_response, [access_token_request]
    processor = PaypalExpress.new(host: 'http://testhost', processor_settings: @processor_settings, gateway: gateway, accounts: accounts, permissions: permissions)
  
    result = processor.get_access_token 'token', 'verifier'

    permissions.verify
    assert_equal 'accesstoken', result[:access_token]
    assert_equal 'tokenSecret', result[:access_token_secret]
  end

  test 'get_access_token raises PaymentError if success? is false' do
    gateway = Minitest::Mock.new
    accounts = Minitest::Mock.new
    permissions = Minitest::Mock.new
    access_token_request = Minitest::Mock.new
    permissions.expect :build_get_access_token, access_token_request, [{ token: 'token', verifier: 'verifier' }]
    access_token_response = Minitest::Mock.new
    access_token_response.expect :success?, false
    permissions.expect :get_access_token, access_token_response, [access_token_request]
    error = Minitest::Mock.new
    error.expect :message, 'Oh No, Error!'
    access_token_response.expect :error, [error]
    processor = PaypalExpress.new(host: 'http://testhost', processor_settings: @processor_settings, gateway: gateway, accounts: accounts, permissions: permissions)
  
    assert_raises PaymentProcessor::PaymentError do
      processor.get_access_token 'token', 'verifier'
    end
    permissions.verify
    error.verify
  end

  test 'get_permissions calls paypal and gets permissions for user' do
    gateway = Minitest::Mock.new
    accounts = Minitest::Mock.new
    permissions = Minitest::Mock.new
    permissions_request = Minitest::Mock.new
    permissions.expect :build_get_permissions, permissions_request, [{ token: 'token' }]
    get_permissions_response = Minitest::Mock.new
    get_permissions_response.expect :success?, true
    get_permissions_response.expect :scope, 'scope'
    permissions.expect :get_permissions, get_permissions_response, [permissions_request]
    processor = PaypalExpress.new(host: 'http://testhost', processor_settings: @processor_settings, gateway: gateway, accounts: accounts, permissions: permissions)
  
    result = processor.get_permissions 'token'

    permissions.verify
    assert_equal 'scope', result
  end

  test 'get_permissions raises PaymentError if success? is false' do
    gateway = Minitest::Mock.new
    accounts = Minitest::Mock.new
    permissions = Minitest::Mock.new
    permissions_request = Minitest::Mock.new
    permissions.expect :build_get_permissions, permissions_request, [{ token: 'token' }]
    get_permissions_response = Minitest::Mock.new
    get_permissions_response.expect :success?, false
    get_permissions_response.expect :scope, 'scope'
    permissions.expect :get_permissions, get_permissions_response, [permissions_request]
    error = Minitest::Mock.new
    error.expect :message, 'Oh No, Error!'
    get_permissions_response.expect :error, [error]
    processor = PaypalExpress.new(host: 'http://testhost', processor_settings: @processor_settings, gateway: gateway, accounts: accounts, permissions: permissions)
  
    assert_raises PaymentProcessor::PaymentError do
      processor.get_permissions 'token'
    end
    permissions.verify
    error.verify
  end
end
