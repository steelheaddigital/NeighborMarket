require 'test_helper'

class SellerHelperTest < ActionView::TestCase
  test 'payment_processor_message returns correct message if InPerson payment processor and no payment instructions' do
    user = users(:approved_seller_user)
    user.user_in_person_setting.payment_instructions = ''

    PaymentProcessorSetting.stub :current_processor_type, 'InPerson' do
      result = payment_processor_message(user)

      assert_equal result, 'You must add payment instructions before you can add items for sale. Go to <a href="/user_payment_settings" >payment settings</a> to add your payment instructions.'
    end
  end

  test 'payment_processor_message returns correct message if online payment processor and in person payments allowed and no in person payment and no online payments configured' do
    user = users(:approved_seller_user)
    user.user_in_person_setting.accept_in_person_payments = false
    processor_settings = MiniTest::Mock.new
    processor_settings.expect :allow_in_person_payments, true
    user.stub :online_payment_processor_configured?, false do
      PaymentProcessorSetting.stub :current_processor_type, 'Online' do
        PaymentProcessorSetting.stub :current_settings, processor_settings do 
          result = payment_processor_message(user)

          assert_equal result, 'You must configure payment options before you can add items for sale. Go to <a href="/user_payment_settings" >payment settings</a> to add payment options.'
        end
      end
    end
  end

  test 'payment_processor_message returns correct message if online payment processor and in person payments not allowed and no online processor configured' do
    user = users(:approved_seller_user)
    processor_settings = MiniTest::Mock.new
    processor_settings.expect :allow_in_person_payments, false
    processor_settings.expect :allow_in_person_payments, false
    user.stub :online_payment_processor_configured?, false do
      PaymentProcessorSetting.stub :current_processor_type, 'Online' do
        PaymentProcessorSetting.stub :current_settings, processor_settings do 
          result = payment_processor_message(user)

          assert_equal result, 'You must configure payment options before you can add items for sale. Go to <a href="/user_payment_settings" >payment settings</a> to add payment options.'
        end
      end
    end
  end

  test 'payment_processor_message returns correct message if online payment processor and in person payments allowed and no online processor configured' do
    user = users(:approved_seller_user)
    user.user_in_person_setting.accept_in_person_payments = true
    processor_settings = MiniTest::Mock.new
    processor_settings.expect :allow_in_person_payments, true
    processor_settings.expect :allow_in_person_payments, true
    processor_settings.expect :allow_in_person_payments, true
    user.stub :online_payment_processor_configured?, false do
      PaymentProcessorSetting.stub :current_processor_type, 'Online' do
        PaymentProcessorSetting.stub :current_settings, processor_settings do 
          result = payment_processor_message(user)

          assert_equal result, 'You can accept online payments by going to your <a href="/user_payment_settings" >payment settings</a> and configuring online payment options.'
        end
      end
    end
  end
end
