class CreateBuyers < ActiveRecord::Migration
  def change
    create_table :buyers do |t|
      t.integer :user_id
      t.text :deliveryinstructions
    end
  end
end
