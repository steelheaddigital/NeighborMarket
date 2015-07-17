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

module SellerHelper
  def payment_processor_message(user)
    payment_processor_settings = PaymentProcessorSetting.current_settings
    if PaymentProcessorSetting.current_processor_type == 'InPerson'
      if user.user_in_person_setting.payment_instructions.blank?
        'You must add payment instructions before you can add items for sale. Go to <a href="/user_payment_settings" >payment settings</a> to add your payment instructions.'.html_safe
      end
    else
      if (payment_processor_settings.allow_in_person_payments && !user.user_in_person_setting.accept_in_person_payments && !user.online_payment_processor_configured?) || (!payment_processor_settings.allow_in_person_payments && !user.online_payment_processor_configured?)
        'You must configure payment options before you can add items for sale. Go to <a href="/user_payment_settings" >payment settings</a> to add payment options.'.html_safe
      elsif payment_processor_settings.allow_in_person_payments && user.user_in_person_setting.accept_in_person_payments && !user.online_payment_processor_configured?
        'You can accept online payments by going to your <a href="/user_payment_settings" >payment settings</a> and configuring online payment options.'.html_safe
      end
    end
  end

  def allow_adding_items(user)
    result = true
    payment_processor_settings = PaymentProcessorSetting.current_settings
    if PaymentProcessorSetting.current_processor_type == 'InPerson'
      result = false if user.user_in_person_setting.payment_instructions.blank?
    else
      if payment_processor_settings.allow_in_person_payments
        if user.user_in_person_setting.accept_in_person_payments
          result = false if user.user_in_person_setting.payment_instructions.blank?
        else
          result = false unless user.online_payment_processor_configured?
        end
      else
        result = false unless user.online_payment_processor_configured?
      end
    end
    result
  end
end
