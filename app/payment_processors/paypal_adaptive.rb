module PaymentProcessor
  class PaypalAdaptive < PaymentProcessorBase
    def init
      paypal_options = {
        login: ENV['PAYPAL_API_USERNAME'],
        password: ENV['PAYPAL_API_PASSWORD'],
        signature: ENV['PAYPAL_API_SIGNATURE'],
        appid: ENV['PAYPAL_APP_ID']
      }

      @gateway = ActiveMerchant::Billing::PaypalAdaptivePayment.new(paypal_options)
    end

    def purchase(cart)
      recipients = get_recipients(cart)

      response = gateway.setup_purchase(
        return_url: "#{create_order_url}?gateway=paypal",
        cancel_url: cart_index_url,
        ipn_notification_url: paypal_ipn_notification_orders_url,
        receiver_list: recipients
      )

      gateway.redirect_url_for(response['payKey'])
    end
    
  end
end
