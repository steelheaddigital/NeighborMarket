class Order < ActiveRecord::Base
  has_many :cart_items, :dependent => :destroy
  belongs_to :user
  belongs_to :order_cycle
  
  accepts_nested_attributes_for :cart_items
  attr_accessible :cart_items_attributes
  
  validate :ensure_current_order_cycle
  
  before_save do |order|
    order_cycle_id = OrderCycle.current_cycle_id
    order.order_cycle_id = order_cycle_id
    update_seller_inventory(order)
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
  
  private 
  
  def ensure_current_order_cycle
    current_order_cycle_id = OrderCycle.current_cycle_id
    if order_cycle
      if order_cycle.id != current_order_cycle_id
        errors.add("","Order is not in the current open order cycle and cannot be edited")
      end
    end
  end
  
  def update_seller_inventory(order)
    order.cart_items.each do |item|
      #if the quantity was changed and the cart_item is part of an order
      if item.quantity_changed? and item.order_id
        difference = item.quantity - item.quantity_was
        item.inventory_item.decrement_quantity_available(difference)
      #this is a new or existing order
      else
        item.inventory_item.decrement_quantity_available(item.quantity)
      end
    end
  end
  
end
