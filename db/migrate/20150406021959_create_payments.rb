class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.string :transaction_id
      t.integer :receiver_id
      t.integer :sender_id
      t.decimal :amount
      t.string :status
      t.datetime :payment_date
      t.timestamps
    end
    
    add_reference :payments, :order, index: true
    add_index :payments, :receiver_id
    add_index :payments, :sender_id
  end
end
