class AddCanceledToOrders < ActiveRecord::Migration
  def change
    add_column :orders, :canceled, :boolean, default: false
  end
end
