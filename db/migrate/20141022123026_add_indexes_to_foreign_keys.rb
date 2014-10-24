class AddIndexesToForeignKeys < ActiveRecord::Migration
  def change
    add_index :cart_items, :cart_id
    add_index :cart_items, :inventory_item_id
    add_index :cart_items, :order_id
    
    add_index :carts, :user_id
    
    add_index :inventory_item_change_requests, :inventory_item_id
    add_index :inventory_item_change_requests, :user_id
    
    add_index :inventory_items, :top_level_category_id
    add_index :inventory_items, :second_level_category_id
    add_index :inventory_items, :user_id 
    
    add_index :order_change_requests, :order_id
    add_index :order_change_requests, :user_id
    
    add_index :orders, :user_id
    add_index :orders, :order_cycle_id
    
    add_index :roles_users, [:role_id, :user_id]
    
    add_index :order_cycles, :status
  end
end
