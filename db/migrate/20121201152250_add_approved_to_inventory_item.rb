class AddApprovedToInventoryItem < ActiveRecord::Migration
  def change
    add_column :inventory_items, :approved, :boolean, :default => true
  end
end
