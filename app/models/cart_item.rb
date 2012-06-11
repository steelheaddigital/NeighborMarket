class CartItem < ActiveRecord::Base
  belongs_to :cart
  belongs_to :inventory_item
  
  attr_accessible :inventory_item_id, :quantity
end