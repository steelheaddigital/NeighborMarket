class CreateOrderChangeRequests < ActiveRecord::Migration
  def change
    create_table :order_change_requests do |t|
      t.integer :user_id
      t.integer :order_id
      t.text :description
      t.boolean :complete, :default => false

      t.timestamps
    end
  end

end
