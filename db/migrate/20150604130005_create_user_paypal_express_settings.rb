class CreateUserPaypalExpressSettings < ActiveRecord::Migration
  def change
    create_table :user_paypal_express_settings do |t|
      t.integer :payment_processor_setting_id, default: 1
      t.boolean :accept_in_person_payments, default: true
      t.string :account_id
      t.string :account_type
      t.string :email_address
      t.text :access_token
      t.text :access_token_secret 
      t.timestamps
    end

    add_reference :user_paypal_express_settings, :user, index: true
  end
end
