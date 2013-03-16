class CreateInventoryItemOrderCycle < ActiveRecord::Migration
  def up
    rename_table :inventory_items_order_cycles, :inventory_item_order_cycles
    add_column :inventory_item_order_cycles, :id, :primary_key
  end

  def down
  end
end
