class AddAutopostToInventoryItems < ActiveRecord::Migration
  def change
    add_column :inventory_items, :autopost, :boolean, :default => false
    add_column :inventory_items, :autopost_quantity, :integer 
  end
end
