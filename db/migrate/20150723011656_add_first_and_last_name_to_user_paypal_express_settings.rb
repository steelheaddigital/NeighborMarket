class AddFirstAndLastNameToUserPaypalExpressSettings < ActiveRecord::Migration
  def change
    add_column :user_paypal_express_settings, :first_name, :string
    add_column :user_paypal_express_settings, :last_name, :string
  end
end
