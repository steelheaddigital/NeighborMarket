class CreateInventoryItemsOrderCyclesTable < ActiveRecord::Migration
  def self.up
    create_table :inventory_items_order_cycles, :id => false do |t|
      t.integer :inventory_item_id, :null => false
      t.integer :order_cycle_id, :null => false
    end
    add_index :inventory_items_order_cycles, [:inventory_item_id, :order_cycle_id], :unique => true, :name => "inventory_items_order_cycles_index"
  end

  def self.down
    drop_table :inventory_items_order_cycles
  end
end
