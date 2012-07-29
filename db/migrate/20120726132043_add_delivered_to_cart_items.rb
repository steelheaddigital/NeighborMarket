class AddDeliveredToCartItems < ActiveRecord::Migration
  def change
    add_column :cart_items, :delivered, :boolean, :default => false
  end
end
