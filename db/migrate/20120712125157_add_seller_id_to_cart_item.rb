class AddSellerIdToCartItem < ActiveRecord::Migration
  def change
    add_column :cart_items, :seller_id, :integer
  end
end
