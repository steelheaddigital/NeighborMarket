require 'test_helper'

class UserPaypalExpressSettingTest < ActiveSupport::TestCase
  test 'verify_account calls Paypal to verify account and returns request permissions url' do
    setting = user_paypal_express_settings(:one)
    mock_payment_processor = Minitest::Mock.new
    mock_payment_processor.expect :verify_account, { account_id: 123, account_type: 'BUSINESS' }, ['approved_seller_user@test.com', 'Approved', 'Seller']
    mock_payment_processor.expect :request_permissions, 'http://request_permissions'

    setting.stub :payment_processor, mock_payment_processor do
      result = setting.verify_account true
      
      saved_setting = UserPaypalExpressSetting.find(setting.id)
      mock_payment_processor.verify
      assert_equal '123', saved_setting.account_id
      assert_equal 'BUSINESS', saved_setting.account_type
      assert_equal 'http://request_permissions', result
    end
  end

  test 'verify_account calls Paypal to verify account and returns true if request_permissions is false' do
    setting = user_paypal_express_settings(:one)
    mock_payment_processor = Minitest::Mock.new
    mock_payment_processor.expect :verify_account, { account_id: 123, account_type: 'BUSINESS' }, ['approved_seller_user@test.com', 'Approved', 'Seller']

    setting.stub :payment_processor, mock_payment_processor do
      result = setting.verify_account false
      
      saved_setting = UserPaypalExpressSetting.find(setting.id)
      mock_payment_processor.verify
      assert_equal '123', saved_setting.account_id
      assert_equal 'BUSINESS', saved_setting.account_type
      assert_equal true, result
    end
  end

  test 'verify_account adds error and does not save if verify_account fails' do
    setting = user_paypal_express_settings(:one)
    mock_payment_processor = Minitest::Mock.new
    mock_payment_processor.expect :verify_account, nil do
      fail PaymentProcessor::PaymentError, 'Oh No! Verify Account Fails'
    end

    setting.stub :payment_processor, mock_payment_processor do
      result = setting.verify_account true
      
      assert_equal nil, setting.account_id
      assert_equal nil, setting.account_type
      assert_equal nil, result
      assert_equal setting.errors.full_messages.last, 'Oh No! Verify Account Fails'
    end
  end

  test 'verify_account adds error and does not save if request_permissions fails' do
    setting = user_paypal_express_settings(:one)
    mock_payment_processor = Minitest::Mock.new
    mock_payment_processor.expect :verify_account, { account_id: 123, account_type: 'BUSINESS' }, ['approved_seller_user@test.com', 'Approved', 'Seller']
    mock_payment_processor.expect :request_permissions, nil do
      fail PaymentProcessor::PaymentError, 'Oh No! Verify Account Fails'
    end

    setting.stub :payment_processor, mock_payment_processor do
      result = setting.verify_account true

      saved_setting = UserPaypalExpressSetting.find(setting.id)
      assert_equal 'F913C4N2+//XYDmwd5HlVw==$bG6FtSKRBusM6+oR/DYMdw==', saved_setting.account_id
      assert_equal 'BUSINESS', saved_setting.account_type
      assert_equal nil, result
      assert_equal setting.errors.full_messages.last, 'Oh No! Verify Account Fails'
    end
  end

  test 'grant_permissions calls paypal and sets fields' do
    setting = user_paypal_express_settings(:one)
    mock_payment_processor = Minitest::Mock.new
    mock_payment_processor.expect :get_access_token, { access_token: 'access_token', access_token_secret: 'access_token_secret' }, ['token', 'verifier']

    setting.stub :payment_processor, mock_payment_processor do
      result = setting.grant_permissions 'token', 'verifier'
      
      saved_setting = UserPaypalExpressSetting.find(setting.id)
      assert_equal 'access_token', saved_setting.access_token
      assert_equal 'access_token_secret', saved_setting.access_token_secret
      assert_equal true, result
    end
  end

  test 'grant_permissions adds error and does not save if get_access_token call to paypal fails' do
    setting = user_paypal_express_settings(:one)
    mock_payment_processor = Minitest::Mock.new
    mock_payment_processor.expect :get_access_token, nil do
      fail PaymentProcessor::PaymentError, 'Oh No! Verify Account Fails'
    end

    setting.stub :payment_processor, mock_payment_processor do
      result = setting.grant_permissions 'token', 'verifier'
      
      assert_equal nil, setting.access_token
      assert_equal nil, setting.access_token_secret
      assert_equal nil, result
      assert_equal setting.errors.full_messages.last, 'Oh No! Verify Account Fails'
    end
  end

  test 'permissions_granted? returns true if access_token and access_token_secret are not nil' do
    setting = UserPaypalExpressSetting.new
    setting.access_token = 'token'
    setting.access_token_secret = 'secret'

    result = setting.permissions_granted?

    assert_equal true, result
  end

  test 'account_confirmed? returns true if account_id and access_token and access_token_secret are not nil' do
    setting = UserPaypalExpressSetting.new
    setting.access_token = 'token'
    setting.access_token_secret = 'secret'
    setting.account_id = 'id'

    result = setting.account_confirmed?

    assert_equal true, result
  end

  test 'permission_granted? calls paypal and returns true if access_token is not nil and user has permission' do
    setting = UserPaypalExpressSetting.new
    setting.access_token = 'token'
    mock_payment_processor = Minitest::Mock.new
    mock_payment_processor.expect :get_permissions, ['REFUND'], ['token']

    setting.stub :payment_processor, mock_payment_processor do
      result = setting.permission_granted? 'REFUND'

      mock_payment_processor.verify
      assert_equal true, result
    end
  end

  test 'permission_granted? calls paypal and returns false if access_token is not nil and user does not have permission' do
    setting = UserPaypalExpressSetting.new
    setting.access_token = 'token'
    mock_payment_processor = Minitest::Mock.new
    mock_payment_processor.expect :get_permissions, [''], ['token']

    setting.stub :payment_processor, mock_payment_processor do
      result = setting.permission_granted? 'REFUND'

      mock_payment_processor.verify
      assert_equal false, result
    end
  end

  test 'does not validate if account_type is not business' do
    setting = UserPaypalExpressSetting.new 
    setting.account_type = 'PERSONAL'

    assert_equal false, setting.valid?
    assert_equal 'You must have a Paypal business account. You can <a href="https://www.paypal.com/signup/account">sign up for a new Paypal business account</a> or <a href="https://www.paypal.com/us/cgi-bin/webscr?cmd=_run-signup-upgrade-link">upgrade your existing account</a>.', setting.errors.messages[:base].first
  end
end
