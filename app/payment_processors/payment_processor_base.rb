require 'singleton'

module PaymentProcessor
  class PaymentProcessorBase
    include Singleton 
    
    attr_reader :gateway

    protected

    attr_writer :gateway

    def get_recipients(cart)
      cart.cart_items.joins(inventory_item: [:user])
        .select('users.email AS email, SUM(cart_items.quantity * inventory_items.price) AS amount')
        .group('users.email')
        .map { |item| { email: item.email, amount: item.amount, primary: false } }
    end
  end
end
