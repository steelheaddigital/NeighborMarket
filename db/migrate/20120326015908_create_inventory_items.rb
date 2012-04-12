class CreateInventoryItems < ActiveRecord::Migration
  def change
    create_table :inventory_items do |t|
      t.integer :top_level_category_id
      t.integer :second_level_category_id
      t.integer :user_id
      t.string :name
      t.decimal :price, :precision => 8, :scale => 2
      t.string :price_unit
      t.integer :quantity_available
      t.text :description

      t.timestamps
    end
  end
end
