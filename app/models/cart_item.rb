class CartItem < ActiveRecord::Base
  belongs_to :cart
  belongs_to :inventory_item
  belongs_to :order
  before_destroy :ensure_no_order
  
  attr_accessible :inventory_item_id, :quantity
  validate :validate_quantity
  
  def validate_quantity
    if self.quantity > inventory_item.quantity_available
      errors.add(:quantity, "cannot be greater than quantity available of #{inventory_item.quantity_available} for item #{inventory_item.name}")
    end
  end
  
  def total_price
    inventory_item.price * quantity
  end
  
  private
  
  def ensure_no_order
    if !self.order
      return true
    end
    return false
  end
  
end