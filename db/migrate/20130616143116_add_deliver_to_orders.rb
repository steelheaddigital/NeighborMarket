class AddDeliverToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :deliver, :boolean, :default => false
  end
end
