class CreateSellers < ActiveRecord::Migration
  def change
    create_table :sellers do |t|
      t.text :payment_instructions
      t.boolean :approved, :default => false, :null => false
      t.string :listing_approval_style, :default => "manual", :null => false
    end
  end
end
