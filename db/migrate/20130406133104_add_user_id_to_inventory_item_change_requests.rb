class AddUserIdToInventoryItemChangeRequests < ActiveRecord::Migration
  def change
    add_column :inventory_item_change_requests, :user_id, :integer
  end
end
