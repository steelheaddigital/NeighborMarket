class Cart < ActiveRecord::Base
  has_many :cart_items
  belongs_to :user
  
  attr_accessible :user_id
  
  def add_inventory_item(inventory_item_id, quantity)
    current_item = cart_items.find_by_inventory_item_id(inventory_item_id)
    
     if current_item
       current_item.quantity += quantity.to_i
     else
       current_item = self.cart_items.build(:inventory_item_id => inventory_item_id, :quantity => quantity.to_i)
       current_item.cart_id = self.id
    end
     
    current_item
  end
  
  def total_price
    cart_items.to_a.sum { |item| item.total_price }
  end
end