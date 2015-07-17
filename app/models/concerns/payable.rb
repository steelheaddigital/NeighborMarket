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

module Payable
  extend ActiveSupport::Concern

  def online_payment_only?
    return true unless PaymentProcessorSetting.current_processor_type == 'InPerson' || PaymentProcessorSetting.current_settings.allow_in_person_payments
    cart_items.all? { |cart_item| cart_item.inventory_item.user.user_in_person_setting.accept_in_person_payments == false }
  end

  def in_person_payment_only?
    return true if PaymentProcessorSetting.current_processor_type == 'InPerson'
    cart_items.all? { |cart_item| cart_item.inventory_item.user.online_payment_processor_configured? == false }
  end

  def all_items_accept_online_payment?
    return true if online_payment_only?
    cart_items.all? { |cart_item| cart_item.inventory_item.user.online_payment_processor_configured? == true }
  end

  def all_items_accept_in_person_payment?
    return true if in_person_payment_only?
    cart_items.all? { |cart_item| cart_item.inventory_item.user.user_in_person_setting.accept_in_person_payments == true }
  end

  def items_with_online_payment_only?
    PaymentProcessorSetting.current_processor_type != 'InPerson' && cart_items.any? { |cart_item| cart_item.inventory_item.user.user_in_person_setting.accept_in_person_payments == false }
  end

  def items_with_in_person_payment_only?
    return true if PaymentProcessorSetting.current_processor_type == 'InPerson'
    cart_items.any? { |cart_item| cart_item.inventory_item.user.online_payment_processor_configured? == false }
  end
end
