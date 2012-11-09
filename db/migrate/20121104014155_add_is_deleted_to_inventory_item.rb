class AddIsDeletedToInventoryItem < ActiveRecord::Migration
  add_column :inventory_items, :is_deleted, :boolean, :default => false
end
