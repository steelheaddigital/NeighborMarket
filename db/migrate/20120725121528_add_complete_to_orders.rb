class AddCompleteToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :complete, :boolean, :default => false
  end
end
