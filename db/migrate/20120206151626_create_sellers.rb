class CreateSellers < ActiveRecord::Migration
  def change
    create_table :sellers do |t|
      t.text :payment_instructions
    end
  end
end
