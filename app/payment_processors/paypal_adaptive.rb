module PaymentProcessor
  class PaypalAdaptive
    attr_reader :gateway

    def init
      paypal_options = {
        login: ENV['PAYPAL_API_USERNAME'],
        password: ENV['PAYPAL_API_PASSWORD'],
        signature: ENV['PAYPAL_API_SIGNATURE'],
        appid: ENV['PAYPAL_APP_ID']
      }

      @gateway = ActiveMerchant::Billing::PaypalAdaptivePayment.new(paypal_options)
    end



    private

    attr_writer :gateway
  end
end
