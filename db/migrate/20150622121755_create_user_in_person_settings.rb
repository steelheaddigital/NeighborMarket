class CreateUserInPersonSettings < ActiveRecord::Migration
  def up
    create_table :user_in_person_settings do |t|
      t.boolean :accept_in_person_payments, default: true
      t.text :payment_instructions
    end
    add_reference :user_in_person_settings, :user, index: true

    execute <<-SQL 
      INSERT INTO user_in_person_settings(user_id, payment_instructions)
      SELECT id, payment_instructions
      FROM users
      WHERE payment_instructions IS NOT NULL
    SQL

    remove_column :user_paypal_express_settings, :accept_in_person_payments
    remove_column :users, :payment_instructions
  end

  def down
    add_column :user_paypal_express_settings, :accept_in_person_payments, :boolean, default: true
    add_column :users, :payment_instructions, :text

    execute <<-SQL 
      UPDATE users
      SET payment_instructions = user_in_person_settings.payment_instructions
      FROM user_in_person_settings
      WHERE user_in_person_settings.user_id = users.id
    SQL

    drop_table :user_in_person_settings
  end
end
