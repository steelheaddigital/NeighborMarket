class CartItem < ActiveRecord::Base
  belongs_to :cart
  belongs_to :inventory_item
  belongs_to :order
  
  attr_accessible :inventory_item_id, :quantity, :seller_id
  
  def total_price
    inventory_item.price * quantity
  end
  
end