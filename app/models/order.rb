class Order < ActiveRecord::Base
  has_many :cart_items, dependent: :destroy
  belongs_to :user
  
  def add_inventory_items_from_cart(cart)
    cart.cart_items.each do |item|
      item.cart_id = nil
      cart_items << item
    end
    
  end
end
