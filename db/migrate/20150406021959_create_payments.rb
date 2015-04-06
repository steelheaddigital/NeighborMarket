class CreatePayments < ActiveRecord::Migration
  def change
    create_table :payments do |t|
      t.string :transaction_id
      t.string :receiver_email
      t.string :receiver_id
      t.string :payer_email
      t.string :payer_id
      t.decimal :payment_gross
      t.decimal :payment_fee
      t.string :payment_status
      t.integer :quantity
      t.datetime :payment_date
      t.timestamps
    end
    
    add_reference :payments, :orders, index: true
  end
end
