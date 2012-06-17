class CreateCartItems < ActiveRecord::Migration
  def change
    create_table :cart_items do |t|
      t.integer :cart_id
      t.integer :inventory_item_id
      t.integer :quantity, :default => 1
      t.timestamps
    end
  end
end