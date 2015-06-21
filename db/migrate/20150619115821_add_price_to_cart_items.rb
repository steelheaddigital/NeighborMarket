class AddPriceToCartItems < ActiveRecord::Migration
  def change
    add_column :cart_items, :price, :decimal
  end
end
