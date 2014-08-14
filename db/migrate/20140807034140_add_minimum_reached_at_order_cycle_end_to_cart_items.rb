class AddMinimumReachedAtOrderCycleEndToCartItems < ActiveRecord::Migration
  def change
    add_column :cart_items, :minimum_reached_at_order_cycle_end, :boolean, :default => true
  end
end
