class AddMinimumToInventoryItem < ActiveRecord::Migration
  def change
    add_column :inventory_items, :minimum, :integer
  end
end
