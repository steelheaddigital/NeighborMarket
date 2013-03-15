class RemoveOrderCycleIdFromInventoryItems < ActiveRecord::Migration
  def up
    remove_column :inventory_items, :order_cycle_id if column_exists?(:inventory_items, :order_cycle_id)
    ActiveRecord::Base.connection.execute("TRUNCATE inventory_items")
  end

  def down
    add_column :inventory_items, :order_cycle_id, :integer
  end
end
