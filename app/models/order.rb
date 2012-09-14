class Order < ActiveRecord::Base
  has_many :cart_items, dependent: :destroy
  belongs_to :user
  belongs_to :order_cycle
  
  before_save do |order|
    order_cycle_id = OrderCycle.current_cycle_id
    order.order_cycle_id = order_cycle_id
  end
  
  def add_inventory_items_from_cart(cart)
    cart.cart_items.each do |item|
      item.cart_id = nil
      cart_items << item
    end
  end
  
  def total_price
    cart_items.to_a.sum { |item| item.total_price }
  end
  
end
