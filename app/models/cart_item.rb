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

class CartItem < ActiveRecord::Base
  belongs_to :cart
  belongs_to :inventory_item
  belongs_to :order
  has_and_belongs_to_many :payments
  
  attr_accessible :inventory_item_id, :quantity, :price
  attr_accessor :current_user
  
  validate :validate_quantity,
           :ensure_current_order_cycle
           
  validate :validate_can_edit, on: :update
  
  before_save :check_for_refunds
  before_destroy :refund_all_payments
  after_destroy :check_order
  
  def can_edit?
    user_editable || order.nil?
  end
  
  def check_for_refunds
    return unless order && quantity_changed?

    difference = quantity_was - quantity
    if difference > 0
      amount_to_refund = difference * price
      payments.select { |p| p.net_total > 0 }.each do |payment|
        if amount_to_refund > payment.net_total
          if payment.refund_all
            amount_to_refund -= payment.net_total
          else
            merge_payment_errors(payment)
            fail ActiveRecord::Rollback
          end
        else
          unless payment.refund(amount_to_refund)
            merge_payment_errors(payment)
            fail ActiveRecord::Rollback
          end
          break
        end
      end
    end
  end

  def refund_all_payments
    return true unless order
    
    refund_payments!
    inventory_item.increment_quantity_available(quantity)
  end
  
  def total_price
    price * quantity
  end
  
  def online_payment_only?
    inventory_item.user.user_in_person_setting.accept_in_person_payments == false
  end

  def in_person_payment_only?
    inventory_item.user.online_payment_processor_configured? == false
  end

  def can_change_quantity?
    order.nil?
  end

  def refund_payments!
    unless refund_payments
      fail ActiveRecord::Rollback
    end
  end

  def refund_payments
    return unless order
    payments.each do |payment|
      unless payment.refund_all
        merge_payment_errors(payment)
        return false
      end
    end
    true
  end

  def payment_status
    if order.paid_online? && order.payments.count == 0 && inventory_item.user.online_payment_processor_configured?
      'Online payment pending'
    elsif order.paid_online? && order.payments.count > 0 && inventory_item.user.online_payment_processor_configured?
      'Paid online'
    else
      'Due on receipt'
    end
  end

  private
  
  def merge_payment_errors!(payment)
    payment.errors.full_messages.each do |message|
      errors.add(:base, message)
    end
    fail ActiveRecord::Rollback
  end

  def merge_payment_errors(payment)
    payment.errors.full_messages.each do |message|
      errors.add(:base, message)
    end
  end

  def validate_can_edit
    if !can_edit?
      if quantity_was > quantity && cart.nil?
        errors.add(:quantity, "cannot be decreased after your order has been completed. If you need to change this item, please <a href=\"#{Rails.application.routes.url_helpers.new_order_change_request_path(:order_id => self.order.id)}\">send a request</a> to the site manager.".html_safe)
      end
    end
  end
  
  def user_editable
    if current_user
      @user_editable = current_user.manager?
    end
    @user_editable || false
  end
  
  def check_order
    return unless order
    order.cancel if order.cart_items.count == 0 && !order.destroyed? && !order.will_cancel?
  end
  
  def validate_quantity
    inventory_item.reload
    if !order_id.nil?
      if (inventory_item.quantity_available + quantity_was) - quantity < 0
        errors.add(:quantity, "cannot be greater than quantity available of #{inventory_item.quantity_available + quantity_was} for item #{inventory_item.name}")
      end
    else
      if inventory_item.quantity_available - quantity < 0
        errors.add(:quantity, "cannot be greater than quantity available of #{inventory_item.quantity_available} for item #{inventory_item.name}")
      end
    end
  end
  
  def ensure_current_order_cycle
    errors.add('', 'there is no open order cycle at this time.  Please check back later.') unless OrderCycle.current_cycle
  end
  
end
