class Cart < ActiveRecord::Base
  has_many :cart_items, :dependent => :destroy
  belongs_to :user
  
  attr_accessible :user_id
  
  def add_inventory_item(inventory_item_id, quantity)
    current_item = cart_items.find_by_inventory_item_id(inventory_item_id)
    
     if current_item
       current_item.quantity += quantity.to_i
     else
       inventory_item = InventoryItem.find(inventory_item_id)
       current_item = self.cart_items.build(:inventory_item_id => inventory_item_id, :quantity => quantity.to_i, :seller_id => inventory_item.user_id)
       current_item.cart_id = self.id
    end
     
    current_item
  end
  
  def total_price
    cart_items.to_a.sum { |item| item.total_price }
  end
end