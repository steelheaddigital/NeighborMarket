class CreateSellers < ActiveRecord::Migration
  def change
    create_table :sellers do |t|
      t.text :payment_instructions
      t.boolean :approved, :default => false, :null => false
    end
  end
end
