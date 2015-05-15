require 'test_helper'

class PaymentProcessorTest < ActiveSupport::TestCase
  include PaymentProcessor

  test 'payment_processor returns correct processor instance' do
    result = payment_processor

    assert result.is_a? PaypalExpress
  end
end
