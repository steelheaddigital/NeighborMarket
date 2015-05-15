#
#Copyright 2013 Neighbor Market
#
#This file is part of Neighbor Market.
#
#Neighbor Market is free software: you can redistribute it and/or modify
#it under the terms of the GNU General Public License as published by
#the Free Software Foundation, either version 3 of the License, or
#(at your option) any later version.
#
#Neighbor Market is distributed in the hope that it will be useful,
#but WITHOUT ANY WARRANTY; without even the implied warranty of
#MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#GNU General Public License for more details.
#
#You should have received a copy of the GNU General Public License
#along with Neighbor Market.  If not, see <http://www.gnu.org/licenses/>.
#

module PaymentProcessor
  class InPerson < PaymentProcessorBase
    include Rails.application.routes.url_helpers

    def checkout(cart)
      new_order_path
    end

    def purchase(order, params)
      order.sub_totals.each do |seller_id, amount|
        order.payments << Payment.new(
          receiver_id: seller_id, 
          sender_id: order.user.id, 
          amount: amount,
          processor_type: 'InPerson',
          payment_type: 'pay'
        )
      end
      finish_order_path
    end

    def refund(payment, amount)
      payment.order.payments.create(
        processor_type: 'InPerson',
        payment_type: 'refund',
        receiver_id: payment.receiver_id,
        sender_id: payment.sender_id,
        amount: amount,
        status: 'COMPLETE',
        payment_date: DateTime.now
      )
    end
  end
end
