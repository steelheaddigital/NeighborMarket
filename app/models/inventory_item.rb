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

class InventoryItem < ActiveRecord::Base
  acts_as_indexed :fields => [:name, :description, :top_level_category_name, :second_level_category_name]
  belongs_to :user
  belongs_to :top_level_category, touch: true
  belongs_to :second_level_category, touch: true
  has_many :cart_items
  has_many :inventory_item_order_cycles
  has_many :order_cycles, -> { uniq }, :through => :inventory_item_order_cycles
  has_attached_file :photo, :styles => { :medium => "300x300>", :thumb => "100x100>" }
  
  attr_accessible :top_level_category_id, :second_level_category_id, :name, :price, :price_unit, :quantity_available, :description, :photo, :is_deleted, :approved, :autopost, :autopost_quantity
  attr_accessor :current_user
  
  validates :top_level_category_id, 
    :second_level_category_id,
    :price,
    :price_unit,
    :quantity_available,
    :presence => true
  
  validates :price, :numericality => {:greater_than_or_equal_to => 0.01}
  validates :quantity_available, :numericality => {:greater_than_or_equal_to => 0}
  validates :autopost_quantity, :numericality => {:greater_than_or_equal_to => 0}, :allow_nil => true
  validates :autopost_quantity, :presence => true, :if => :autopost?
  validate :ensure_current_order_cycle
  validate :validate_can_edit, :on => :update
  
  before_destroy :ensure_not_referenced_by_any_cart_item
  before_destroy :validate_can_edit
  before_create :add_to_order_cycle
  after_update :notify_buyers
  
  def autopost?
    self.autopost
  end
  
  def top_level_category_name
    self.top_level_category.name
  end
  
  def second_level_category_name
    self.second_level_category.name
  end
  
  def self.search(keywords)
    scope = self.joins(:order_cycles)
                .where("is_deleted = false AND approved = true AND order_cycles.status = 'current'")
    scope.find_with_index(keywords)
  end
  
  def decrement_quantity_available(quantity)
    self.quantity_available -= quantity
    @user_editable = true
    self.save
  end
  
  def increment_quantity_available(quantity)
    self.quantity_available += quantity
    @user_editable = true
    self.save
  end
  
  def cart_item_quantity_sum(order_cycle_id)
    self.cart_items.joins(:order)
                   .where(:orders => {:order_cycle_id => order_cycle_id})
                   .map{|h| h[:quantity]}.reduce(:+)
  end
  
  def previous_cart_items
    self.cart_items.joins(:order)
                   .where("orders.order_cycle_id != ?", OrderCycle.current_cycle_id)
  end
  
  def paranoid_destroy
  
     #if the inventory item isn't associated with any previous orders then go ahead and destroy it,
     #otherwise, set it's is_deleted property to true to maintain order history
    send_order_modified_emails
    current_cart_items.destroy_all
    if self.previous_cart_items.empty?
      success = self.destroy
    else
      success = self.update_attribute(:is_deleted, true)
    end
    
    return success
  end
  
  def add_to_order_cycle
    order_cycle = OrderCycle.active_cycle
    self.order_cycles << order_cycle if !order_cycle.nil?
  end
  
  def in_current_order_cycle?
    order_cycle = order_cycles.find_by_status("current")
    return !order_cycle.nil?
  end
  
  def current_cart_items
    self.cart_items.includes(:order)
                   .where(:orders => {:order_cycle_id => OrderCycle.current_cycle_id})
  end
  
  def can_edit?
    user_editable || (!in_current_order_cycle? || current_cart_items.empty?)
  end
  
  private
  
  def user_editable
    if current_user
      @user_editable = current_user.manager?
    end
    @user_editable || false
  end
  
  def validate_can_edit
    if !can_edit?
      self.changed.each do |value|
        if(value != "quantity_available")
          field = value.to_sym
          errors.add(field, "cannot be updated during the current order cycle since the inventory item is contained in one or more orders. If you need to change this item, please <a href=\"#{Rails.application.routes.url_helpers.new_inventory_item_change_request_path(:inventory_item_id => self.id)}\">send a request</a> to the site manager.".html_safe)
        end
      end
    end
  end
  
  def ensure_current_order_cycle
    order_cycle = OrderCycle.active_cycle
    if order_cycle.nil?
      errors.add(:base, "Item could not be added. No available order cycle.")
      return false
    else
      return true
    end
  end
  
  def ensure_not_referenced_by_any_cart_item
    if cart_items.empty?
      return true
    else
      errors.add(:base, "Item cannot be destroyed: Cart Items present, use the paranoid_destroy method instead")    
      return false
    end
  end
  
  def notify_buyers
    changed = self.changed
    
    #ignore these fields when deciding whether to send emails
    a = changed.select { |n| n == "quantity_available" || n == "approved" || n == "updated_at" || n == "autopost" || n == "autopost_quantity"}
    
    #send modified emails if non-ignored fields were changed
    send_order_modified_emails if changed.length > a.length
  end
  
  def send_order_modified_emails
    self.current_cart_items.each do |item|
      BuyerMailer.delay.order_modified_mail(self.user, item.order)
    end
  end
  
  def self.autopost(order_cycle)
    InventoryItem.where(:autopost => true).each do |item|
      item.order_cycles << order_cycle
      item.quantity_available = item.autopost_quantity
      item.save
    end
  end
  
end
