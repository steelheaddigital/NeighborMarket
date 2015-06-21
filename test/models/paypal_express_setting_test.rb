require 'test_helper'

class PaypalExpressSettingTest < ActiveSupport::TestCase
  test 'should validate valid setting' do
    setting = paypal_express_settings(:one)
    setting.assign_attributes(username: 'test', password: 'test', api_signature: 'test', app_id: 'test')
    assert setting.valid?
  end

  test 'should not validate if username is empty' do
    setting = paypal_express_settings(:one)
    setting.assign_attributes(username: '', password: 'test', api_signature: 'test', app_id: 'test')
    assert setting.invalid?
  end

  test 'should not validate if password is empty' do
    setting = paypal_express_settings(:two)
    setting.assign_attributes(username: 'test', password: '', api_signature: 'test', app_id: 'test')
    assert setting.invalid?
  end

  test 'should not validate if api_signature is empty' do
    setting = paypal_express_settings(:one)
    setting.assign_attributes(username: 'test', password: 'test', api_signature: '', app_id: 'test')
    assert setting.invalid?
  end

  test 'should not validate if app_id is empty' do
    setting = paypal_express_settings(:one)
    setting.assign_attributes(username: 'test', password: 'test', api_signature: 'test', app_id: '')
    assert setting.invalid?
  end

  test 'should validate empty password if previous password is not empty' do
    setting = paypal_express_settings(:one)
    setting.assign_attributes(username: 'test', password: '', api_signature: 'test', app_id: 'test')
    assert setting.valid?
  end
end
