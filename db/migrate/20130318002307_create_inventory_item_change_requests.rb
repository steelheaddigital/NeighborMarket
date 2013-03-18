class CreateInventoryItemChangeRequests < ActiveRecord::Migration
  def change
    create_table :inventory_item_change_requests do |t|
      t.integer :inventory_item_id
      t.text :description
      t.boolean :complete, :default => false

      t.timestamps
    end
  end
end
