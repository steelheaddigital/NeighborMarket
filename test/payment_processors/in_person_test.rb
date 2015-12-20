require 'test_helper'

class InPersonTest < ActiveSupport::TestCase
    def setup
        @processor = PaymentProcessor::InPerson.new({})
    end

    test 'purchase should add payments to order' do
        order = orders(:current_two)
        cart = carts(:buyer_not_current)

        result = @processor.purchase(order, cart, nil)

        payment = order.payments.first
        assert_equal order.payments.count, 1
        assert_equal payment.receiver_id, users(:unapproved_seller_user).id
        assert_equal payment.sender_id, users(:buyer_user_not_current).id
        assert_equal payment.amount, 100.00
        assert_equal payment.processor_type, 'InPerson'
        assert_equal payment.payment_type, 'pay'
        assert_equal payment.status, 'Pending'
    end

    test 'refund should add refund payments to order' do
        order = orders(:current_two)
        payment = Payment.new
        payment.status = 'Completed'
        payment.receiver_id = 1
        payment.sender_id = 2
        payment.order = order
        payment.save

        result = @processor.refund(payment, 100.00)

        assert_equal result.receiver_id, 1
        assert_equal result.sender_id, 2
        assert_equal result.amount, 100.00
        assert_equal result.processor_type, 'InPerson'
        assert_equal result.payment_type, 'refund'
        assert_equal result.status, 'Completed'
    end

    test 'refund should destroy payment if status is Pending and total amount is refunded' do
        payment = payments(:two)

        assert_difference 'Payment.count', -1 do
            @processor.refund(payment, 20.00)
        end
    end

    test 'refund should update payment amount if status is Pending and total amount is less than payment total' do
        payment = payments(:two)

        @processor.refund(payment, 10.00)
        updated_payment = Payment.find(payment.id)

        assert_equal updated_payment.amount, 10.00
    end
end
