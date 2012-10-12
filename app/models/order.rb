class Order < ActiveRecord::Base
  has_many :cart_items
  belongs_to :user
  belongs_to :order_cycle
  
  accepts_nested_attributes_for :cart_items
  attr_accessible :cart_items_attributes
  
  before_save do |order|
    order_cycle_id = OrderCycle.current_cycle_id
    order.order_cycle_id = order_cycle_id
    update_seller_inventory(order)
  end
  
  before_destroy do |order|
    order.cart_items.each do |item|
      item.inventory_item.increment_quantity_available(item.quantity)
      item.destroy
    end
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
  
  def update_seller_inventory(order)
    order.cart_items.each do |item|
      #if the quantity was changed and the cart_item is part of an order
      if item.quantity_changed? and item.order_id
        difference = item.quantity - item.quantity_was
        item.inventory_item.decrement_quantity_available(difference)
      #this is a new order
      elsif order.id.nil?
        item.inventory_item.decrement_quantity_available(item.quantity)
      end
    end
  end
  
end
