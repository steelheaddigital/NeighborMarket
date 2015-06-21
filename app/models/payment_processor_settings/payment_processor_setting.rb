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

class PaymentProcessorSetting < ActiveRecord::Base
  has_one :paypal_express_setting, -> { where(payment_processor_setting_id: 1) }
  has_many :user_paypal_express_setting, -> { where(payment_processor_setting_id: 1) }
  accepts_nested_attributes_for :paypal_express_setting
  attr_accessible :processor_type, :paypal_express_setting_attributes
end
