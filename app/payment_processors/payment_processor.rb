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
  include PayPal::SDK::AdaptivePayments
  extend ActiveSupport::Autoload
  
  autoload :PaymentProcessorBase
  autoload :PaypalAdaptive

  def payment_processor
    PayPal::SDK.configure(
      mode: Rails.env.production? ? 'live' : 'sandbox',
      username: ENV['PAYPAL_API_USERNAME'],
      password: ENV['PAYPAL_API_PASSWORD'],
      signature: ENV['PAYPAL_API_SIGNATURE'],
      app_id: ENV['PAYPAL_APP_ID']
    )
    host = ENV['HOST']
    gateway = PayPal::SDK::AdaptivePayments.new
    PaypalAdaptive.new(gateway, host)
  end
end
