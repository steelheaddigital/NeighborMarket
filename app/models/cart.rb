class Cart < ActiveRecord::Base
  has_many :cart_items, :dependent => :destroy
  
  def add_inventory_item(inventory_item_id)
    current_item = cart_items.find_by_inventory_item_id(inventory_item_id)
    
     if current_item
       current_item.quantity += 1
     else
       current_item = self.cart_items.build(:inventory_item_id => inventory_item_id)
     end
     
    current_item
  end
end