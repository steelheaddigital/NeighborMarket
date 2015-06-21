class CreatePaypalExpressSettings < ActiveRecord::Migration
  def up
    create_table :paypal_express_settings do |t|
      t.boolean :allow_in_person_payments, default: true
      t.string :username
      t.text :password
      t.text :api_signature
      t.text :app_id
      t.integer :payment_processor_setting_id, default: 1
    end

    execute <<-SQL
      INSERT INTO paypal_express_settings DEFAULT VALUES;
    SQL
  end

  def down
    drop_table :paypal_express_settings
  end
end
