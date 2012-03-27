class CreateInventories < ActiveRecord::Migration
  def change
    create_table :inventories do |t|
      t.integer :top_level_taxonomy_id
      t.integer :second_level_taxonomy_id
      t.integer :user_id
      t.string :name
      t.decimal :price
      t.string :quantity_available
      t.text :description

      t.timestamps
    end
  end
end
