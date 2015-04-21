module PaymentProcessor
  module PaymentProcessorFactory
    def payment_processor
      PaypalAdaptive.instance
    end
  end
end
