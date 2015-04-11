class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.string :transaction_id
      t.string :receiver_id
      t.string :payer_id
      t.decimal :payment_gross
      t.decimal :payment_fee
      t.string :payment_status
      t.datetime :payment_date
      t.timestamps
    end
    
    add_reference :payments, :order, index: true
    add_index :payments, :receiver_id
    add_index :payments, :payer_id
  end
end
