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

    def initialize(args)
    end

    def purchase(order, cart, params)
      cart.in_person_payment_sub_totals.each do |seller_id, amount|
        cart_items = order.cart_items.joins(:inventory_item).where('inventory_items.user_id = ?', seller_id)
        new_payment = Payment.new(
          receiver_id: seller_id, 
          sender_id: order.user.id, 
          amount: amount,
          processor_type: 'InPerson',
          payment_type: 'pay',
          status: 'Pending'
        )
        new_payment.cart_items = cart_items
        order.payments << new_payment
      end
      finish_order_path
    end

    def refund(payment, amount)
      if payment.status == 'Pending'
        payment.destroy
      elsif payment.status == 'Completed'
        payment.refunds.create(
          processor_type: 'InPerson',
          payment_type: 'refund',
          receiver_id: payment.receiver_id,
          sender_id: payment.sender_id,
          amount: amount,
          status: 'Completed',
          payment_date: DateTime.now
        )
      end
    end
  end
end
