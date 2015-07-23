require 'test_helper'

class UserPaypalExpressSettingsControllerTest < ActionController::TestCase
  include Devise::TestHelpers
  
  def setup
    @user  = users(:approved_seller_user)
    sign_in @user
  end

  test 'create redirects to paypal permissions request page' do
    payment_processor = Minitest::Mock.new
    payment_processor.expect :verify_account, { account_id: '123', account_type: 'BUSINESS' }, ['test@test.com', 'Approved', 'Seller']
    payment_processor.expect :request_permissions, 'http://paypal/request/permissions'

    UserPaypalExpressSetting.stub_any_instance :payment_processor, payment_processor do
      post :create, user_paypal_express_setting: { email_address: 'test@test.com', first_name: 'Approved', last_name: 'Seller', accept_in_person_payments: true }

      payment_processor.verify
      assert_not_nil assigns(:settings)
      assert_equal assigns(:settings_view_directory), 'user_paypal_express_settings/form'
      assert_redirected_to 'http://paypal/request/permissions'
    end
  end

  test 'create renders form if verify_account does not return a string' do
    payment_processor = Minitest::Mock.new
    payment_processor.expect :verify_account, { account_id: '123', account_type: 'FAIL' }, ['test@test.com', 'Approved', 'Seller']

    UserPaypalExpressSetting.stub_any_instance :payment_processor, payment_processor do
      post :create, user_paypal_express_setting: { email_address: 'test@test.com', first_name: 'Approved', last_name: 'Seller', accept_in_person_payments: true }

      payment_processor.verify
      assert_not_nil assigns(:settings)
      assert_equal assigns(:settings_view_directory), 'user_paypal_express_settings/form'
      assert_template '_form'
    end
  end

  test 'update redirects to paypal request permissions if REFUND permission not granted' do
    setting = user_paypal_express_settings(:one)
    payment_processor = Minitest::Mock.new
    payment_processor.expect :verify_account, { account_id: '12345', account_type: 'BUSINESS' }, ['approved_seller_user@test.com', 'Approved', 'Seller']
    payment_processor.expect :request_permissions, 'http://paypal/request/permissions'
    payment_processor.expect :get_permissions, [], ['12345']

    UserPaypalExpressSetting.stub_any_instance :payment_processor, payment_processor do
      post :update, commit: 'Verify Account', id: setting.id, user_paypal_express_setting: { email_address: 'approved_seller_user@test.com', first_name: 'Approved', last_name: 'Seller', accept_in_person_payments: true }

      payment_processor.verify
      assert_not_nil assigns(:settings)
      assert_equal assigns(:settings_view_directory), 'user_paypal_express_settings/form'
      assert_redirected_to 'http://paypal/request/permissions'
    end
  end

  test 'update deletes setting if commit is Unlink Account' do
    setting = user_paypal_express_settings(:one)

    post :update, id: setting.id, commit: 'Unlink Account'

    assert_equal assigns(:settings_view_directory), 'user_paypal_express_settings/form'
    assert_nil UserPaypalExpressSetting.find_by(id: setting.id)
    assert_redirected_to user_payment_settings_path
  end

  test 'grant_permissions sets access_token and access_token_secret' do
    payment_processor = Minitest::Mock.new
    payment_processor.expect :get_access_token, { access_token: '123', access_token_secret: '456' }, ['request_token', 'verification_code']

    UserPaypalExpressSetting.stub_any_instance :payment_processor, payment_processor do
      get :grant_permissions, request_token: 'request_token', verification_code: 'verification_code'

      payment_processor.verify
      assert_not_nil assigns(:settings)
      assert_equal assigns(:settings_view_directory), 'user_paypal_express_settings/form'
      assert_equal '123', @user.user_paypal_express_setting.access_token
      assert_equal '456', @user.user_paypal_express_setting.access_token_secret
      assert_redirected_to user_payment_settings_path
    end
  end

  test 'grant_permissions renders form if grant_permissions fails' do
    payment_processor = Minitest::Mock.new
    payment_processor.expect :get_access_token, nil do
      fail PaymentProcessor::PaymentError, 'Oh No!'
    end

    UserPaypalExpressSetting.stub_any_instance :payment_processor, payment_processor do
      get :grant_permissions, request_token: 'request_token', verification_code: 'verification_code'

      assert_not_nil assigns(:settings)
      assert_equal assigns(:settings_view_directory), 'user_paypal_express_settings/form'
      assert_equal '12345', @user.user_paypal_express_setting.access_token
      assert_equal '12345', @user.user_paypal_express_setting.access_token_secret
      assert_template '_form'
    end
  end

  test 'user cannot update settings other than their own"'do
    setting = user_paypal_express_settings(:two)
    
    post :update, id: setting.id
    assert_response :not_found

  end

  test 'anonymous user cannot access protected actions' do
    sign_out @user
    
    setting = user_paypal_express_settings(:one)
        
    post :update, id: setting.id
    assert_redirected_to new_user_session_path
    
    post :create
    assert_redirected_to new_user_session_path
    
    get :grant_permissions, request_token: 'request_token', verification_code: 'verification_code'
    assert_redirected_to new_user_session_path
  end
end
