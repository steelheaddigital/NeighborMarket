require 'test_helper'

class UserInPersonSettingTest < ActiveSupport::TestCase
  test 'should not validate' do
    setting = user_in_person_settings(:one)

    assert setting.valid?
  end

  test 'should not validate if payment_instructions are nil and accept_in_person_payments is true' do
    setting = user_in_person_settings(:one)
    setting.payment_instructions = nil

    assert setting.invalid?
  end

  test 'should not validate if accept_in_person_payments is nil and online_payment_processor is not configured' do
    setting = user_in_person_settings(:two)
    setting.accept_in_person_payments = false

    assert setting.invalid?
    assert_equal 'Accept in person payments cannot be false if no online payment processor is configured', setting.errors.full_messages.first
  end
end
