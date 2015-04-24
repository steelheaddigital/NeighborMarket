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
  class PaymentProcessorBase
    protected    

    def process_payments(order)
      recipients = []
      order.sub_totals.each do |key, value| 
        seller = User.find(key)
        payment = order.payments.create(receiver_id: seller.id, sender_id: order.user.id, payment_gross: value)
        recipients.push(email: seller.email, amount: value, primary: false, invoice_id: payment.id)
      end

      recipients
    end
  end
end
