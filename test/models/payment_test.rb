require 'test_helper'

class OrderTest < ActiveSupport::TestCase
  test 'net_total returns total of payments minus refunds' do
    payment = payments(:one)
    payment.refunds.create(amount: 5.00)

    assert_equal 5.00, payment.net_total
  end

  test 'refund calls payment_processor refund method with correct parameters' do
    payment = payments(:one)
    payment_processor = Minitest::Mock.new
    payment_processor.expect :refund, Payment.new, [payment, 5.00]

    payment.stub :payment_processor, payment_processor do
      payment.refund(5.00)

      payment_processor.verify
    end
  end

  test 'refund_all calls payment_processor refund method with net_total amount' do
    payment = payments(:one)
    payment.refunds.create(amount: 4.00)
    payment_processor = Minitest::Mock.new
    payment_processor.expect :refund, Payment.new, [payment, 6.00]

    payment.stub :payment_processor, payment_processor do
      payment.refund_all

      payment_processor.verify
    end
  end
end
