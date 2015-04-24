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

require 'singleton'

module PaymentProcessor
  class PaypalAdaptive < PaymentProcessorBase
    include ActiveMerchant::Billing::Integrations
    include Rails.application.routes.url_helpers
    include Singleton

    attr_reader :gateway

    def initialize
      paypal_options = {
        login: ENV['PAYPAL_API_USERNAME'],
        password: ENV['PAYPAL_API_PASSWORD'],
        signature: ENV['PAYPAL_API_SIGNATURE'],
        appid: ENV['PAYPAL_APP_ID']
      }

      @host = ENV['HOST']
      self.gateway = ActiveMerchant::Billing::PaypalAdaptivePayment.new(paypal_options)
    end

    def purchase(order)
      recipients = process_payments(order)

      response = gateway.setup_purchase(
        return_url: finish_order_url(id: order.id, host: @host),
        cancel_url: cart_index_url(host: @host),
        ipn_notification_url: payments_confirm_url(host: @host),
        custom: order.id,
        receiver_list: recipients
      )

      gateway.redirect_url_for(response['payKey'])
    end
  

    def confirm(raw_post)
      notify = PaypalAdaptivePayment::Notification.new(raw_post)
      payment = Payment.find_by order_id: notify.invoice
      #if notify.acknowledge
        transactions = notify.params['transaction']
        transactions.each do |transaction| 
          if(payment.transaction_id.nil? || payment.transaction_id != transaction.transaction_id)
            payment = Payment.find(transaction.invoiceId)
            payment.update_attributes(transaction_id: transaction.id_for_sender_txn)
          end
        end
      #end
    end

    private 

    attr_writer :gateway
  end
end
