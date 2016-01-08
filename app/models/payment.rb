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

class Payment < ActiveRecord::Base
  include PaymentProcessor

  belongs_to :order
  belongs_to :receiver, class_name: 'User', foreign_key: 'receiver_id'
  belongs_to :sender, class_name: 'User', foreign_key: 'sender_id'
  has_many :refunds, class_name: 'Payment', foreign_key: 'refunded_payment_id'
  belongs_to :refunded_payment, class_name: 'Payment'
  has_and_belongs_to_many :cart_items

  attr_accessible :transaction_id, :amount, :fee, :status, :payment_date, :receiver_id, :sender_id, :order_id, :processor_type, :payment_type

  def refund_all
    refund(net_total) if net_total > 0
  end

  def refund_all!
    refund!(net_total) if net_total > 0
  end

  def refund(amount)
    refund!(amount)
  rescue PaymentProcessor::PaymentError => e
    errors.add(:base, e.message)
    false
  end

  def refund!(amount)
    if !refundable?
      fail PaymentProcessor::PaymentError, 'Payment is not refundable'
    else
      payment_processor(type: processor_type).refund(self, amount)
    end
  end

  def refundable?
    net_total > 0 && payment_type != 'refund'
  end

  def net_total
    total_refunds = refunds.sum(:amount)
    amount - total_refunds
  end
end
