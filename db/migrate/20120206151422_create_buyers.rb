class CreateBuyers < ActiveRecord::Migration
  def change
    create_table :buyers do |t|
      t.references :user
      t.text :delivery_instructions
    end
  end
end
