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
  extend ActiveSupport::Autoload
  
  autoload :PaymentProcessorBase
  autoload :PaypalExpress

  def payment_processor(options = {})
    processor_type = options[:type].nil? ? PaymentProcessorSetting.first.processor_type : options[:type]
    processor_settings = "#{processor_type}Setting".constantize.first
    processor_class = "PaymentProcessor::#{processor_type}".constantize
    processor_class.new(host: ENV['HOST'], processor_settings: processor_settings)
  end

  def in_person_payment_processor
    PaymentProcessor::InPerson.new({})
  end

  class PaymentError < StandardError; end
end
