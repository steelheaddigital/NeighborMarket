class CartItem < ActiveRecord::Base
  belongs_to :cart
  belongs_to :inventory_item
  belongs_to :order
  
  attr_accessible :inventory_item_id, :quantity
  validate :validate_quantity,
           :ensure_current_order_cycle
  
  def validate_quantity
    if self.order
      if (inventory_item.quantity_available + self.quantity_was) - self.quantity < 0
        errors.add(:quantity, "cannot be greater than quantity available of #{inventory_item.quantity_available + self.quantity_was} for item #{inventory_item.name}")
      end
    else
      if inventory_item.quantity_available - self.quantity < 0
        errors.add(:quantity, "cannot be greater than quantity available of #{inventory_item.quantity_available} for item #{inventory_item.name}")
      end
    end
  end
  
  def total_price
    inventory_item.price * quantity
  end
  
  private
  
  def ensure_current_order_cycle
    if !OrderCycle.current_cycle
      errors.add("","there is no open order cycle at this time.  Please check back later.")
    end
  end
  
end