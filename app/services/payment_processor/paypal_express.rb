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
require 'paypal-sdk-adaptiveaccounts'
require 'paypal-sdk-permissions'

module PaymentProcessor
  class PaypalExpress < PaymentProcessorBase
    include Rails.application.routes.url_helpers

    attr_reader :gateway
    attr_reader :accounts
    attr_reader :permissions

    def initialize(args)
      @host = args[:host]
      @settings = args[:processor_settings]
      @config = {
        username: @settings.username,
        password: @settings.password,
        signature: @settings.api_signature,
        app_id: @settings.app_id
      }

      case @settings.mode
      when 'Test'
        @config[:mode] = 'sandbox'
        @config[:app_id] = 'APP-80W284485P519543T'
        Paypal.sandbox!
      when 'Live'
        @config[:mode] = 'live'
      end

      #allow a mock gateway instance to be passed in to the constructor for testing
      self.gateway = args.key?(:gateway) ? args[:gateway] : Paypal::Express::Request.new(@config)
      self.accounts = args.key?(:accounts) ? args[:accounts] : PayPal::SDK::AdaptiveAccounts::API.new(@config)
      self.permissions = args.key?(:permissions) ? args[:permissions] : PayPal::SDK::Permissions::API.new(@config)
    end

    def checkout(cart, success_callback_url, cancel_callback_url)
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
        success_callback_url,
        cancel_callback_url,
        paypal_options
      )

      response.redirect_uri
    rescue Paypal::Exception::APIError => e
      raise PaymentProcessor::PaymentError, "#{e.message}; Details: #{e.response.details[0].long_message}"
    end

    def purchase(order, cart, params)
      payment_requests = create_payment_requests(cart)
      token = params[:token]
      payer_id = params[:PayerID]

      response = gateway.checkout!(token, payer_id, payment_requests)

      response.payment_info.each do |payment|
        seller = UserPaypalExpressSetting.find_by(email_address: payment.seller_id).user
        cart_items = order.cart_items.joins(:inventory_item).where('inventory_items.user_id = ?', seller.id)
        new_payment = Payment.new(
          receiver_id: seller.id, 
          sender_id: order.user.id, 
          amount: payment.amount.total,
          fee: payment.amount.fee,
          transaction_id: payment.transaction_id,
          status: payment.payment_status,
          payment_date: DateTime.now,
          processor_type: 'PaypalExpress',
          payment_type: 'pay'
        )
        new_payment.cart_items = cart_items
        order.payments << new_payment
      end
    rescue Paypal::Exception::APIError => e
      raise PaymentProcessor::PaymentError, "#{e.message}; Details: #{e.response.details[0].long_message}"
    end

    def refund(payment, amount, options = {})
      if options[:gateway]
        gateway = options[:gateway]
      else
        gateway_config = @config.clone
        gateway_config[:subject] = User.find(payment.receiver_id).user_paypal_express_setting.email_address
        gateway = Paypal::Express::Request.new(gateway_config)
      end

      paypal_options = {
        type: :Partial,
        amount: amount
      }

      response = gateway.refund!(payment.transaction_id, paypal_options)
      reponse_status = response.ack
      if reponse_status == 'Success'
        refund = response.refund
        refund_payment = payment.refunds.create(
          order_id: payment.order_id,
          processor_type: 'PaypalExpress',
          payment_type: 'refund',
          receiver_id: payment.receiver_id,
          sender_id: payment.sender_id,
          amount: refund.amount.gross,
          fee: refund.amount.fee,
          transaction_id: refund.transaction_id,
          status: 'Completed',
          payment_date: DateTime.now
        )

        refund_payment
      else
        fail PaymentProcessor::PaymentError, "Paypal refund request failed with status #{reponse_status}"
      end
    rescue Paypal::Exception::APIError => e
      raise PaymentProcessor::PaymentError, "#{e.message}; Details: #{e.response.details[0].long_message}"
    end

    def verify_account(email_address, first_name, last_name)
      verified_status_request = accounts.build_get_verified_status emailAddress: email_address, firstName: first_name, lastName: last_name, matchCriteria: 'NAME'
      verified_status_response = accounts.get_verified_status(verified_status_request)

      if verified_status_response.success?
        {
          status: verified_status_response.accountStatus,
          account_id: verified_status_response.userInfo.account_id,
          email_address: verified_status_response.userInfo.emailAddress,
          account_type: verified_status_response.userInfo.accountType
        }
      else
        fail PaymentProcessor::PaymentError, "#{verified_status_response.error[0].message}"
      end
    end

    def request_permissions
      permissions_request = permissions.build_request_permissions scope: ['REFUND'], callback: grant_permissions_user_paypal_express_settings_url(host: @host)
      permissions_response = permissions.request_permissions(permissions_request)

      if permissions_response.success?
        permissions.grant_permission_url(permissions_response)
      else
        fail PaymentProcessor::PaymentError, "#{permissions_response.error[0].message}"
      end
    end

    def get_access_token(request_token, verifier)
      access_token_request = permissions.build_get_access_token(token: request_token, verifier: verifier)
      access_token_response = permissions.get_access_token(access_token_request)

      if access_token_response.success?
        {
          access_token: access_token_response.token,
          access_token_secret: access_token_response.tokenSecret
        }
      else
        fail PaymentProcessor::PaymentError, "#{access_token_response.error[0].message}"
      end
    end

    def get_permissions(token)
      get_permissions_request = permissions.build_get_permissions(token: token)
      get_permissions_response = permissions.get_permissions(get_permissions_request)

      if get_permissions_response.success?
        get_permissions_response.scope
      else
        fail PaymentProcessor::PaymentError, "#{get_permissions_response.error[0].message}"
      end
    end

    private 

    attr_writer :gateway
    attr_writer :accounts
    attr_writer :permissions

    def create_payment_requests(cart)
      payment_requests = []
      cart.online_payment_sub_totals.each_with_index do |sub_total, index|
        seller_user_id = sub_total[0]
        seller = User.find(seller_user_id)
        request = Paypal::Payment::Request.new(
          currency_code: :USD,
          amount: sub_total[1],
          seller_id: seller.user_paypal_express_setting.email_address,
          request_id: "CART#{cart.id}-PAYMENT#{index}")
        payment_requests.push(request)
      end

      payment_requests
    end
  end
end
