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

class PaypalExpressSetting < ActiveRecord::Base
  belongs_to :payment_processor_setting

  crypt_keeper :password, :api_signature, encryptor: :aes_new, key: "#{Rails.application.secrets.secret_key_base}", salt: "#{Rails.application.secrets.secret_key_salt}"

  attr_accessible :username, :password, :api_signature, :allow_in_person_payments

  validates :password, presence: true, if: -> { password_was.nil? }
  validates :username,
    :api_signature,
    presence: true
end
