class AddOrderCycleIdToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :order_cycle_id, :integer
  end
end
