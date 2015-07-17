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

class UserInPersonSetting < ActiveRecord::Base
  belongs_to :user

  attr_accessible :accept_in_person_payments, :payment_instructions

  validates :payment_instructions, presence: true, if: :accept_in_person_payments, on: :update
  validate :validate_online_payment_processor_configured

  private

  def validate_online_payment_processor_configured
    if !accept_in_person_payments && !user.online_payment_processor_configured?
      errors.add(:accept_in_person_payments, 'cannot be false if no online payment processor is configured')
    end
  end
end
