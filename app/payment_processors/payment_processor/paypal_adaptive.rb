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

require 'paypal-sdk-adaptivepayments'

module PaymentProcessor
  class PaypalAdaptive < PaymentProcessorBase
    include Rails.application.routes.url_helpers
    include PayPal::SDK::AdaptivePayments

    attr_reader :gateway

    def initialize(gateway, host)
      @host = host
      self.gateway = gateway
    end

    def purchase(order)
      payment = process_payments(order)

      receiver_list = {}
      payment[:recipients].each do |r|
        receiver = [{ amount: r[:amount], invoiceId: r[:payment_id], email: r[:seller].email }]
        receiver_list[:receiver] = receiver
      end

      pay = gateway.build_pay(
        actionType: 'PAY',
        currencyCode: 'USD',
        returnUrl: finish_order_url(id: order.id, host: @host),
        cancelUrl: cart_index_url(host: @host),
        ipnNotificationUrl: payments_confirm_url(host: @host),
        reverseAllParallelPaymentsOnError: true,
        receiverList: receiver_list
      )

      response = gateway.pay(pay)
      if response.success? && response.payment_exec_status != 'ERROR'
        gateway.payment_url(response)
      else
        fail response.error[0].message
      end
    end
  

    def confirm(request)
      if gateway.ipn_valid?(request.raw_post)
        request.params['transaction'].each do |_index, params|
          payment_id = params['invoiceId']
          transaction_id = params['id_for_sender']
          status = params['status_for_sender_txn']
          receiver_email = params['receiver']
          amount = params['amount']
          payment = Payment.find(payment_id)

          next unless receiver_email == payment.receiver.email && amount.to_f == payment.amount
          if payment.transaction_id.nil?
            payment.update_attributes(transaction_id: transaction_id, status: status, payment_date: DateTime.now)
          else
            payment.update_attributes(status: status)
          end
        end
      else
        Rails.logger.error "Failed to verify Paypal's IPN notification"
      end
    end

    private 

    attr_writer :gateway
  end
end
