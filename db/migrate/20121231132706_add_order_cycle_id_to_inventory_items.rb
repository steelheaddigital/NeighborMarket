class AddOrderCycleIdToInventoryItems < ActiveRecord::Migration
  def change
    add_column :inventory_items, :order_cycle_id, :integer
    InventoryItem.update_all(:order_cycle_id => OrderCycle.current_cycle.id) if OrderCycle.current_cycle
  end
end
