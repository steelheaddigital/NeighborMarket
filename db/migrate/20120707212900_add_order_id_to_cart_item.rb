class AddOrderIdToCartItem < ActiveRecord::Migration
  def change
    add_column :cart_items, :order_id, :integer
  end
end
