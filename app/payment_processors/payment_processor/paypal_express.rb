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
  class PaypalExpress < PaymentProcessorBase
    include Rails.application.routes.url_helpers

    attr_reader :gateway

    def initialize(args)
      @host = args[:host]
      @settings = args[:processor_settings]
      config = {
        username: @settings.username,
        password: @settings.password,
        signature: @settings.api_signature
      }
      #allow a mock gateway instance to be passed in to the constructor for testing
      self.gateway = args.key?(:gateway) ? args[:gateway] : Paypal::Express::Request.new(config)
    end

    def checkout(cart)
      payment_requests = create_payment_requests(cart)

      paypal_options = {
        no_shipping: true,
        allow_note: false,
        pay_on_paypal: true,
        solution_type: 'Sole', #allows checkout with no PayPal account
        landing_page: 'Billing' #shows page with credit card options
      }

      response = gateway.setup(
        payment_requests,
        new_order_url(host: @host),
        cart_index_url(host: @host),
        paypal_options
      )

      response.redirect_uri
    rescue Paypal::Exception::APIError => e
      raise PaymentProcessor::PaymentError, e.response.long_message
    end

    def purchase(order, cart, params)
      payment_requests = create_payment_requests(cart)
      token = params[:token]
      payer_id = params[:PayerID]

      response = gateway.checkout!(token, payer_id, payment_requests)

      response.payment_info.each do |payment|
        seller = User.find_by(email: payment.seller_id)
        order.payments << Payment.new(
          receiver_id: seller.id, 
          sender_id: order.user.id, 
          amount: payment.amount.total,
          transaction_id: payment.transaction_id,
          status: payment.payment_status,
          payment_date: DateTime.now,
          processor_type: 'PaypalExpress',
          payment_type: 'pay'
        )
      end

      finish_order_path
    rescue Paypal::Exception::APIError => e
      raise PaymentProcessor::PaymentError, e.response.long_message
    end

    def refund(payment, amount)
      paypal_options = {
        type: :Partial,
        amount: amount
      }
      response = gateway.refund!(payment.transaction_id, paypal_options)
      reponse_status = response.ack
      if reponse_status == 'Success'
        refund = response.refund
        new_payment = payment.order.payments.create(
          processor_type: 'PaypalExpress',
          payment_type: 'refund',
          receiver_id: payment.receiver_id,
          sender_id: payment.sender_id,
          amount: refund.amount.gross,
          transaction_id: refund.transaction_id,
          status: 'COMPLETE',
          payment_date: DateTime.now
        )

        new_payment
      else
        fail PaymentProcessor::PaymentError, "Paypal refund request failed with status #{reponse_status}"
      end
    rescue Paypal::Exception::APIError => e
      raise PaymentProcessor::PaymentError, e.response.long_message
    end

    private 

    attr_writer :gateway

    def create_payment_requests(cart)
      payment_requests = []
      cart.sub_totals.each do |seller_id, amount| 
        seller = User.find(seller_id)
        request = Paypal::Payment::Request.new(
          currency_code: :USD,
          amount: amount,
          seller_id: seller.email)
        payment_requests.push(request)
      end

      payment_requests
    end
  end
end
