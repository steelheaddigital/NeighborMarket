class InventoryItem < ActiveRecord::Base
  acts_as_indexed :fields => [:name, :description, :top_level_category_name, :second_level_category_name]
  belongs_to :user
  belongs_to :top_level_category
  belongs_to :second_level_category
  has_many :cart_items
  belongs_to :order_cycle
  has_attached_file :photo, :styles => { :medium => "300x300>", :thumb => "100x100>" }
  
  attr_accessible :top_level_category_id, :second_level_category_id, :name, :price, :price_unit, :quantity_available, :description, :photo, :is_deleted, :approved
  
  validates :top_level_category_id, 
    :second_level_category_id,
    :price,
    :price_unit,
    :quantity_available,
    :presence => true
  
  validates :price, :numericality => {:greater_than_or_equal_to => 0.01}
  validates :quantity_available, :numericality => {:greater_than_or_equal_to => 0}
  
  before_destroy :ensure_not_referenced_by_any_cart_item
  before_create :add_order_cycle_id
  
  def add_order_cycle_id
    self.order_cycle = OrderCycle.current_cycle if self.order_cycle_id.nil?
  end
  
  def top_level_category_name
    self.top_level_category.name
  end
  
  def second_level_category_name
    self.second_level_category.name
  end
  
  def self.search(keywords)
    scope = self.joins(:order_cycle)
                .where("quantity_available > 0 AND is_deleted = false AND approved = true AND order_cycles.status = 'current'")
    scope.find_with_index(keywords)
  end
  
  def decrement_quantity_available(quantity)
    self.quantity_available -= quantity
    self.save
  end
  
  def increment_quantity_available(quantity)
    self.quantity_available += quantity
    self.save
  end
  
  def cart_item_quantity_sum
    self.cart_items.where("order_id IS NOT NULL").map{|h| h[:quantity]}.reduce(:+)
  end
  
  def previous_cart_items
    self.cart_items.joins(:order)
                   .where("orders.order_cycle_id != ?", OrderCycle.current_cycle_id)
  end
  
  def paranoid_destroy
    current_cart_items = self.cart_items.joins(:order)
                   .where(:orders => {:order_cycle_id => OrderCycle.current_cycle_id})
  
     #if the inventory item isn't associated with any previous orders then go ahead and destroy it,
     #otherwise, set it's is_deleted property to true to maintain order history
    send_order_modified_emails(self.user, current_cart_items)
    current_cart_items.destroy_all
    if self.previous_cart_items.empty?
      success = self.destroy
    else
      success = self.update_attribute(:is_deleted, true)
    end
    
    return success
  end
  
  def copy_to_new_cycle
    current_order_cycle = OrderCycle.where("status = ? OR status = ?", "current", "pending").last()
    new_item = self.dup
    new_item.order_cycle_id = current_order_cycle.id
    new_item.photo = self.photo
    new_item.save
  end
  
  private
  
  def ensure_not_referenced_by_any_cart_item
    if cart_items.empty?
      return true
    else
      errors.add(:base, "Item cannot be destroyed: Cart Items present, use the paranoid_destroy method instead")    
      return false
    end
  end
  
  def send_order_modified_emails(seller, cart_items)
    cart_items.each do |item|
      BuyerMailer.delay.order_modified_mail(seller, item.order)
      managers = Role.find_by_name("manager").users 
       managers.each do |manager|
         ManagerMailer.delay.seller_modified_order_mail(seller, manager, item.order)
       end
    end
  end
  
end
